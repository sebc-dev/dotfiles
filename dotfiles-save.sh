#!/bin/bash
#
# Script pour sauvegarder les modifications des dotfiles vers GitHub
# Usage: ~/dotfiles-save.sh [message de commit optionnel]
#

set -e

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Fonction dotfiles
dotfiles() {
    git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" "$@"
}

echo -e "${BLUE}==>${NC} ${GREEN}Sauvegarde des dotfiles...${NC}"

# Vérifier s'il y a des modifications
if dotfiles diff --quiet && dotfiles diff --cached --quiet; then
    echo -e "${YELLOW}[!]${NC} Aucune modification à sauvegarder"
    dotfiles status
    exit 0
fi

# Afficher les modifications
echo -e "\n${BLUE}Modifications détectées:${NC}"
dotfiles status --short

# Ajouter les fichiers modifiés (seulement ceux déjà trackés)
dotfiles add -u

# Message de commit
if [ -n "$1" ]; then
    COMMIT_MSG="$1"
else
    COMMIT_MSG="Update dotfiles $(date '+%Y-%m-%d %H:%M')"
fi

# Commit
dotfiles commit -m "$COMMIT_MSG"

# Push
echo -e "\n${BLUE}==>${NC} ${GREEN}Push vers GitHub...${NC}"
dotfiles push

echo -e "\n${GREEN}[✓]${NC} Dotfiles sauvegardés avec succès!"
