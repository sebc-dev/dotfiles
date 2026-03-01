# ~/.config/zsh/tools.zsh - Initialisation des outils externes

# --- Starship prompt ---
if command -v starship &>/dev/null; then
    eval "$(starship init zsh)"
fi

# --- Zoxide (cd intelligent) ---
if command -v zoxide &>/dev/null; then
    eval "$(zoxide init zsh)"
fi

# --- fzf (fuzzy finder) ---
if command -v fzf &>/dev/null; then
    # Thème Gruvbox Material pour fzf
    export FZF_DEFAULT_OPTS="
        --height=40% --layout=reverse --border=rounded
        --color=bg+:#3c3836,bg:#282828,spinner:#d8a657,hl:#a9b665
        --color=fg:#d4be98,header:#a9b665,info:#7daea3,pointer:#d8a657
        --color=marker:#d8a657,fg+:#d4be98,prompt:#e78a4e,hl+:#a9b665
    "
    # Utiliser fd si disponible (plus rapide que find)
    if command -v fd &>/dev/null; then
        export FZF_DEFAULT_COMMAND="fd --type f --hidden --follow --exclude .git"
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
        export FZF_ALT_C_COMMAND="fd --type d --hidden --follow --exclude .git"
    elif command -v fdfind &>/dev/null; then
        export FZF_DEFAULT_COMMAND="fdfind --type f --hidden --follow --exclude .git"
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
        export FZF_ALT_C_COMMAND="fdfind --type d --hidden --follow --exclude .git"
    fi
fi
