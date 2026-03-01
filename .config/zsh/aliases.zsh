# ~/.config/zsh/aliases.zsh - Alias personnels

# --- Navigation (zoxide) ---
alias cd="z"
alias zi="z -i"
alias ..="cd .."
alias ...="cd ../.."

# --- Listing amélioré (eza) ---
if command -v eza &>/dev/null; then
    alias ls="eza --icons --group-directories-first"
    alias ll="eza -la --icons --group-directories-first --git"
    alias lt="eza -la --icons --tree --level=2 --git"
    alias la="eza -a --icons --group-directories-first"
else
    alias ll="ls -lAh --color=auto"
    alias la="ls -A --color=auto"
fi

# --- Outils modernisés ---
command -v bat  &>/dev/null && alias cat="bat --paging=never"
command -v batcat &>/dev/null && alias cat="batcat --paging=never" && alias bat="batcat"
command -v rg   &>/dev/null && alias grep="rg"
command -v fd   &>/dev/null || alias fd="fdfind"  # Nom du paquet Debian

# --- Git raccourcis perso ---
alias gs="git status --short --branch"
alias gl="git log --oneline --graph --decorate -15"
alias gd="git diff"
alias gds="git diff --staged"

# --- Dotfiles (bare repo) ---
alias dotfiles='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
alias ds='dotfiles status --short'
alias da='dotfiles add'
alias dc='dotfiles commit'

# --- Docker raccourcis ---
alias dps="docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'"
alias dcp="docker compose"

# --- Utilitaires ---
alias reload="exec zsh"
alias path='echo -e ${PATH//:/\\n}'
alias ports="ss -tulnp"
alias myip="curl -s ifconfig.me"
alias h="history | tail -20"

# --- Confirmations de sécurité ---
alias rm="rm -i"
alias mv="mv -i"
alias cp="cp -i"
