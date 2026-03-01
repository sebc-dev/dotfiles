#!/bin/bash
#
# Script pour sauvegarder les modifications des dotfiles vers GitHub
#
# Usage:
#   ~/dotfiles-save.sh                       # Sauvegarde les fichiers trackés modifiés
#   ~/dotfiles-save.sh "mon message"         # Avec message de commit personnalisé
#   ~/dotfiles-save.sh --new fichier1 [...]  # Ajoute et sauvegarde de nouveaux fichiers
#   ~/dotfiles-save.sh --dry-run             # Affiche ce qui serait fait sans exécuter
#

set -euo pipefail

# --- Vérification de la locale ---
if ! locale -a 2>/dev/null | grep -qi "fr_FR.utf-\?8"; then
    echo -e "\033[0;31m[✗]\033[0m Locale fr_FR.UTF-8 manquante."
    echo "  Exécute d'abord : sudo locale-gen fr_FR.UTF-8"
    exit 1
fi

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

dotfiles() {
    git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" "$@"
}

# --- Parser les arguments ---
DRY_RUN=false
ADD_NEW=false
NEW_FILES=()
COMMIT_MSG=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run|-n)
            DRY_RUN=true
            shift
            ;;
        --new|-a)
            ADD_NEW=true
            shift
            # Collecter tous les fichiers passés après --new
            while [[ $# -gt 0 && ! "$1" =~ ^-- ]]; do
                NEW_FILES+=("$1")
                shift
            done
            ;;
        --help|-h)
            echo "Usage: dotfiles-save.sh [options] [message de commit]"
            echo ""
            echo "Options:"
            echo "  --new, -a FILE [FILE...]  Ajouter de nouveaux fichiers au tracking"
            echo "  --dry-run, -n             Afficher sans exécuter"
            echo "  --help, -h                Afficher cette aide"
            exit 0
            ;;
        *)
            COMMIT_MSG="$1"
            shift
            ;;
    esac
done

echo -e "${BLUE}==>${NC} ${GREEN}Sauvegarde des dotfiles...${NC}"

# --- Mode --new : ajouter de nouveaux fichiers ---
if $ADD_NEW; then
    if [[ ${#NEW_FILES[@]} -eq 0 ]]; then
        echo -e "${RED}[✗]${NC} --new nécessite au moins un fichier"
        echo "  Exemple : dotfiles-save.sh --new .config/zsh/custom.zsh"
        exit 1
    fi

    for file in "${NEW_FILES[@]}"; do
        if [[ ! -f "$HOME/$file" ]]; then
            echo -e "${RED}[✗]${NC} Fichier introuvable : ~/$file"
            exit 1
        fi
        if $DRY_RUN; then
            echo -e "${YELLOW}[dry-run]${NC} dotfiles add ~/$file"
        else
            dotfiles add "$HOME/$file"
            echo -e "${GREEN}[+]${NC} Ajouté : $file"
        fi
    done
fi

# --- Vérifier s'il y a des modifications ---
if dotfiles diff --quiet && dotfiles diff --cached --quiet && ! $ADD_NEW; then
    echo -e "${YELLOW}[!]${NC} Aucune modification à sauvegarder"
    dotfiles status
    exit 0
fi

# --- Afficher les modifications ---
echo -e "\n${BLUE}Modifications détectées :${NC}"
dotfiles status --short

if $DRY_RUN; then
    echo -e "\n${YELLOW}[dry-run]${NC} Aucune action effectuée."
    exit 0
fi

# --- Ajouter les fichiers trackés modifiés ---
dotfiles add -u

# --- Message de commit ---
if [[ -z "$COMMIT_MSG" ]]; then
    # Générer un message descriptif automatique
    CHANGED=$(dotfiles diff --cached --name-only | head -5 | tr '\n' ', ' | sed 's/,$//')
    COMMIT_MSG="update: $CHANGED ($(date '+%Y-%m-%d %H:%M'))"
fi

# --- Commit ---
dotfiles commit -m "$COMMIT_MSG"

# --- Push ---
echo -e "\n${BLUE}==>${NC} ${GREEN}Push vers GitHub...${NC}"
dotfiles push

echo -e "\n${GREEN}[✓]${NC} Dotfiles sauvegardés avec succès !"
