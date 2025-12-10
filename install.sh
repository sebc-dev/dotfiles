#!/bin/bash
#
# Script d'installation des dotfiles et outils shell
# Usage: curl -fsSL https://raw.githubusercontent.com/sebc-dev/dotfiles/master/.dotfiles-install.sh | bash
#

set -e

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_step() {
    echo -e "\n${BLUE}==>${NC} ${GREEN}$1${NC}"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

# Vérifier si une commande existe
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# --- 1. DOTFILES ---
print_step "Installation des dotfiles..."

if [ -d "$HOME/.dotfiles" ]; then
    print_warning "Le dossier ~/.dotfiles existe déjà. Skipping clone."
else
    git clone --bare https://github.com/sebc-dev/dotfiles.git "$HOME/.dotfiles"
    print_success "Repo dotfiles cloné"
fi

# Fonction dotfiles
dotfiles() {
    git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" "$@"
}

# Backup des fichiers existants si conflit
print_step "Checkout des dotfiles..."
if ! dotfiles checkout 2>/dev/null; then
    print_warning "Conflit détecté. Backup des fichiers existants..."
    mkdir -p "$HOME/.dotfiles-backup"
    dotfiles checkout 2>&1 | grep -E "^\s+" | awk '{print $1}' | while read -r file; do
        mkdir -p "$HOME/.dotfiles-backup/$(dirname "$file")"
        mv "$HOME/$file" "$HOME/.dotfiles-backup/$file"
        print_warning "Backup: $file -> .dotfiles-backup/$file"
    done
    dotfiles checkout
fi
dotfiles config --local status.showUntrackedFiles no
print_success "Dotfiles installés"

# --- 2. ZSH ---
print_step "Installation de Zsh..."
if command_exists zsh; then
    print_success "Zsh déjà installé ($(zsh --version))"
else
    sudo apt update && sudo apt install -y zsh
    print_success "Zsh installé"
fi

# --- 3. OH-MY-ZSH ---
print_step "Installation de Oh-My-Zsh..."
if [ -d "$HOME/.oh-my-zsh" ]; then
    print_success "Oh-My-Zsh déjà installé"
else
    RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    print_success "Oh-My-Zsh installé"
fi

# --- 4. PLUGINS ZSH ---
print_step "Installation des plugins Oh-My-Zsh..."

# zsh-autosuggestions
if [ -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]; then
    print_success "zsh-autosuggestions déjà installé"
else
    git clone https://github.com/zsh-users/zsh-autosuggestions "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
    print_success "zsh-autosuggestions installé"
fi

# zsh-syntax-highlighting
if [ -d "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]; then
    print_success "zsh-syntax-highlighting déjà installé"
else
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
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
print_step "Installation des outils CLI (eza, ripgrep, tmux, fzf, bat)..."
sudo apt update
sudo apt install -y eza ripgrep tmux fzf bat fd-find
print_success "Outils CLI installés"

# --- 8. NVM & NODE ---
print_step "Installation de NVM et Node.js..."
if [ -d "$HOME/.nvm" ]; then
    print_success "NVM déjà installé"
else
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
    print_success "NVM installé"
fi

# Charger NVM et installer Node
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
if command_exists node; then
    print_success "Node.js déjà installé ($(node --version))"
else
    nvm install 22
    nvm use 22
    nvm alias default 22
    print_success "Node.js 22 installé"
fi

# --- 9. FONTS (JetBrains Mono Nerd) ---
print_step "Installation de JetBrains Mono Nerd Font..."
FONT_DIR="$HOME/.local/share/fonts"
if ls "$FONT_DIR"/JetBrains* >/dev/null 2>&1; then
    print_success "JetBrains Mono Nerd Font déjà installée"
else
    mkdir -p "$FONT_DIR"
    cd "$FONT_DIR"
    curl -fLO https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/JetBrainsMono.zip
    unzip -o JetBrainsMono.zip
    rm JetBrainsMono.zip
    fc-cache -fv >/dev/null 2>&1
    print_success "JetBrains Mono Nerd Font installée"
fi

# --- 10. CHANGER LE SHELL PAR DÉFAUT ---
print_step "Configuration du shell par défaut..."
if [ "$SHELL" = "$(which zsh)" ]; then
    print_success "Zsh est déjà le shell par défaut"
else
    print_warning "Changement du shell par défaut vers Zsh..."
    chsh -s "$(which zsh)"
    print_success "Shell par défaut changé vers Zsh"
fi

# --- TERMINÉ ---
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}   Installation terminée avec succès!   ${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Pour appliquer les changements:"
echo -e "  ${YELLOW}exec zsh${NC}  ou ouvre un nouveau terminal"
echo ""
echo "Commandes dotfiles disponibles:"
echo -e "  ${BLUE}dotfiles status${NC}      - Voir les modifications"
echo -e "  ${BLUE}dotfiles add <file>${NC}  - Ajouter un fichier"
echo -e "  ${BLUE}dotfiles commit${NC}      - Commiter les changements"
echo -e "  ${BLUE}dotfiles push${NC}        - Pousser vers GitHub"
echo ""
print_warning "N'oublie pas de configurer la police JetBrains Mono Nerd dans ton terminal!"
