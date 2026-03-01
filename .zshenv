# ~/.zshenv - Chargé par TOUS les shells zsh (interactifs et non-interactifs)
# Ne mettre ici QUE les variables d'environnement

# --- XDG Base Directory ---
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

# --- Zsh config location ---
export ZDOTDIR="$HOME"

# --- PATH de base ---
typeset -U path  # Déduplique automatiquement le PATH

path=(
    "$HOME/.local/bin"
    "$HOME/bin"
    $path
)

# --- Volta (Node.js) ---
export VOLTA_HOME="$HOME/.volta"
path=("$VOLTA_HOME/bin" $path)

# --- Cargo/Rust ---
[[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

# --- Éditeur par défaut ---
export EDITOR="code --wait"
export VISUAL="$EDITOR"

# --- Langue ---
export LANG="${LANG:-fr_FR.UTF-8}"
export LC_ALL="${LC_ALL:-fr_FR.UTF-8}"
