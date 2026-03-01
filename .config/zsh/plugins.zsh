# ~/.config/zsh/plugins.zsh - Oh-My-Zsh avec chargement optimisé

export ZSH="$HOME/.oh-my-zsh"

# --- Désactiver le thème OMZ (Starship gère le prompt) ---
ZSH_THEME=""

# --- Performance : désactiver les checks inutiles ---
DISABLE_AUTO_UPDATE="true"             # Pas de check à chaque lancement
DISABLE_UNTRACKED_FILES_DIRTY="true"   # Accélère git status dans les gros repos
DISABLE_MAGIC_FUNCTIONS="true"         # Évite les ralentissements au copier-coller

# --- Plugins (seulement l'essentiel) ---
# git             : alias (ga, gc, gco, gst, gl, gp...)
# docker-compose  : alias et complétion
# Les 2 plugins externes sont chargés manuellement après pour le lazy loading
plugins=(git docker-compose)

# Charger OMZ
source "$ZSH/oh-my-zsh.sh"

# --- Lazy loading des plugins externes (chargés après le prompt) ---
# Autosuggestions
if [[ -d "$ZSH/custom/plugins/zsh-autosuggestions" ]]; then
    export ZSH_AUTOSUGGEST_STRATEGY=(history completion)
    export ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
    export ZSH_AUTOSUGGEST_MANUAL_REBIND=1  # Évite les rebinds coûteux
    source "$ZSH/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

# Syntax highlighting (doit être chargé EN DERNIER)
if [[ -d "$ZSH/custom/plugins/zsh-syntax-highlighting" ]]; then
    source "$ZSH/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi
