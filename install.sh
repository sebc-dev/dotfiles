#!/bin/bash
#
# Script d'installation des dotfiles et outils shell
# Usage: curl -fsSL https://raw.githubusercontent.com/sebc-dev/dotfiles/master/install.sh | bash
#
# Idempotent : peut être relancé plusieurs fois sans problème
#

set -euo pipefail

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_step()    { echo -e "\n${BLUE}==>${NC} ${GREEN}$1${NC}"; }
print_warning() { echo -e "${YELLOW}[!]${NC} $1"; }
print_error()   { echo -e "${RED}[✗]${NC} $1"; }
print_success() { echo -e "${GREEN}[✓]${NC} $1"; }

command_exists() { command -v "$1" >/dev/null 2>&1; }
is_wsl() { grep -qEi "(Microsoft|WSL)" /proc/version 2>/dev/null; }

dotfiles() {
    git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" "$@"
}

# --- 0. PRÉREQUIS ---
print_step "Vérification des prérequis..."

if ! command_exists apt; then
    print_error "Ce script nécessite apt (Debian/Ubuntu). Abandon."
    exit 1
fi

ARCH=$(dpkg --print-architecture 2>/dev/null || uname -m)
print_success "Architecture détectée : $ARCH"

sudo apt update
sudo apt install -y git curl unzip
print_success "Prérequis installés"

# --- 1. DOTFILES ---
print_step "Installation des dotfiles..."

if [ -d "$HOME/.dotfiles" ]; then
    print_warning "Dotfiles déjà présents. Mise à jour..."
    dotfiles fetch origin
    dotfiles reset --hard FETCH_HEAD
    print_success "Dotfiles mis à jour"
else
    git clone --bare https://github.com/sebc-dev/dotfiles.git "$HOME/.dotfiles"
    print_success "Repo dotfiles cloné"
fi

print_step "Checkout des dotfiles..."
if ! dotfiles checkout 2>/dev/null; then
    print_warning "Conflit détecté. Backup des fichiers existants..."
    BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    dotfiles checkout 2>&1 | grep -E "^\s+" | awk '{print $1}' | while read -r file; do
        if [ -f "$HOME/$file" ]; then
            mkdir -p "$BACKUP_DIR/$(dirname "$file")"
            mv "$HOME/$file" "$BACKUP_DIR/$file"
            print_warning "Backup: $file"
        fi
    done
    dotfiles checkout
fi
dotfiles config --local status.showUntrackedFiles no
print_success "Dotfiles installés"

# --- 2. ZSH ---
print_step "Installation de Zsh..."
if command_exists zsh; then
    print_success "Zsh déjà installé ($(zsh --version | head -1))"
else
    sudo apt install -y zsh
    print_success "Zsh installé"
fi

# --- 3. OH-MY-ZSH ---
print_step "Installation de Oh-My-Zsh..."
if [ -d "$HOME/.oh-my-zsh" ]; then
    print_success "Oh-My-Zsh déjà installé"
else
    RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    # Supprimer le .zshrc généré par OMZ (on utilise le nôtre)
    [ -f "$HOME/.zshrc" ] && rm "$HOME/.zshrc"
    dotfiles checkout -- .zshrc
    print_success "Oh-My-Zsh installé"
fi

# --- 4. PLUGINS ZSH ---
print_step "Installation des plugins Oh-My-Zsh..."

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

if [ -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    print_success "zsh-autosuggestions déjà installé"
else
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    print_success "zsh-autosuggestions installé"
fi

if [ -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    print_success "zsh-syntax-highlighting déjà installé"
else
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
    print_success "zsh-syntax-highlighting installé"
fi

# --- 5. STARSHIP ---
print_step "Installation de Starship..."
if command_exists starship; then
    print_success "Starship déjà installé ($(starship --version | head -1))"
else
    curl -sS https://starship.rs/install.sh | sh -s -- -y
    print_success "Starship installé"
fi

# --- 6. ZOXIDE ---
print_step "Installation de Zoxide..."
if command_exists zoxide; then
    print_success "Zoxide déjà installé ($(zoxide --version))"
else
    curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
    print_success "Zoxide installé"
fi

# --- 7. OUTILS CLI ---
print_step "Installation des outils CLI..."

# Paquets disponibles dans les repos Ubuntu standards
CLI_PACKAGES="ripgrep fzf fd-find unzip"

# eza nécessite un repo spécifique sur Ubuntu < 24.04
if apt-cache show eza >/dev/null 2>&1; then
    CLI_PACKAGES="$CLI_PACKAGES eza"
    print_success "eza disponible dans les repos"
else
    print_warning "eza non disponible dans les repos apt. Installation via cargo si disponible..."
    if command_exists cargo; then
        cargo install eza 2>/dev/null && print_success "eza installé via cargo" || print_warning "Échec installation eza"
    else
        print_warning "Skipping eza (ni apt ni cargo disponible)"
    fi
fi

# bat : nom du paquet varie selon la version d'Ubuntu
if apt-cache show bat >/dev/null 2>&1; then
    CLI_PACKAGES="$CLI_PACKAGES bat"
else
    CLI_PACKAGES="$CLI_PACKAGES batcat"
fi

sudo apt install -y $CLI_PACKAGES
print_success "Outils CLI installés"

# --- 8. VOLTA & NODE ---
print_step "Installation de Volta et Node.js..."
export VOLTA_HOME="$HOME/.volta"
if [ -d "$VOLTA_HOME" ]; then
    print_success "Volta déjà installé"
else
    curl https://get.volta.sh | bash -s -- --skip-setup
    print_success "Volta installé"
fi

export PATH="$VOLTA_HOME/bin:$PATH"
if command_exists node; then
    print_success "Node.js déjà installé ($(node --version))"
else
    volta install node
    print_success "Node.js installé via Volta"
fi

# --- 9. FONTS (JetBrains Mono Nerd) ---
print_step "Installation de JetBrains Mono Nerd Font..."
FONT_DIR="$HOME/.local/share/fonts"
if ls "$FONT_DIR"/JetBrains* >/dev/null 2>&1; then
    print_success "JetBrains Mono Nerd Font déjà installée"
else
    mkdir -p "$FONT_DIR"
    FONT_VERSION="v3.3.0"
    (
        cd "$FONT_DIR"
        curl -fLO "https://github.com/ryanoasis/nerd-fonts/releases/download/${FONT_VERSION}/JetBrainsMono.zip"
        unzip -o JetBrainsMono.zip
        rm -f JetBrainsMono.zip
    )
    fc-cache -fv >/dev/null 2>&1
    print_success "JetBrains Mono Nerd Font installée"
fi

# --- 10. CRÉER LES RÉPERTOIRES XDG ---
print_step "Création des répertoires XDG..."
mkdir -p "$HOME/.local/state/zsh"   # Pour l'historique zsh
mkdir -p "$HOME/.cache"
print_success "Répertoires créés"

# --- 11. CHANGER LE SHELL PAR DÉFAUT ---
print_step "Configuration du shell par défaut..."
ZSH_PATH=$(which zsh)
CURRENT_SHELL=$(getent passwd "$USER" | cut -d: -f7)

if [ "$CURRENT_SHELL" = "$ZSH_PATH" ]; then
    print_success "Zsh est déjà le shell par défaut"
else
    if chsh -s "$ZSH_PATH" 2>/dev/null; then
        print_success "Shell par défaut changé vers Zsh (via chsh)"
    elif is_wsl; then
        print_warning "WSL détecté. Tentative alternative..."
        if sudo usermod -s "$ZSH_PATH" "$USER" 2>/dev/null; then
            print_success "Shell par défaut changé vers Zsh (via usermod)"
        else
            if ! grep -q "exec zsh" "$HOME/.bashrc" 2>/dev/null; then
                cat >> "$HOME/.bashrc" <<'EOF'

# Lancer zsh automatiquement (WSL fix)
if [ -t 1 ] && [ -x "$(command -v zsh)" ]; then
    exec zsh
fi
EOF
                print_success "Zsh sera lancé automatiquement via .bashrc (WSL workaround)"
            else
                print_success "Workaround WSL déjà en place dans .bashrc"
            fi
        fi
    else
        print_error "Impossible de changer le shell. Lance 'chsh -s $(which zsh)' manuellement."
    fi
fi

# --- TERMINÉ ---
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}   Installation terminée avec succès!   ${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Pour appliquer les changements :"
echo -e "  ${YELLOW}Ferme et réouvre ton terminal${NC}"
echo ""
echo "Commandes dotfiles disponibles :"
echo -e "  ${BLUE}dotfiles status${NC}      - Voir les modifications"
echo -e "  ${BLUE}dotfiles add <file>${NC}  - Ajouter un fichier"
echo -e "  ${BLUE}dotfiles commit${NC}      - Commiter les changements"
echo -e "  ${BLUE}dotfiles push${NC}        - Pousser vers GitHub"
echo -e "  ${BLUE}~/dotfiles-save.sh${NC}   - Sauvegarder en une commande"
echo ""
print_warning "N'oublie pas de configurer la police JetBrains Mono Nerd dans ton terminal !"
