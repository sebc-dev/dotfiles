# ~/.zshrc - Shell interactif uniquement
# Les variables d'environnement sont dans ~/.zshenv

# --- Helper : source si le fichier existe ---
_source_if() { [[ -f "$1" ]] && source "$1"; }

# --- Détection WSL ---
_is_wsl() { grep -qEi "(Microsoft|WSL)" /proc/version 2>/dev/null; }

# --- Chargement modulaire ---
_source_if "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/options.zsh"
_source_if "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/plugins.zsh"
_source_if "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/aliases.zsh"
_source_if "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/tools.zsh"

# WSL uniquement
_is_wsl && _source_if "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/wsl.zsh"

# Surcharges locales (non versionné)
_source_if "$HOME/.zshrc.local"

# Nettoyage
unfunction _source_if _is_wsl
