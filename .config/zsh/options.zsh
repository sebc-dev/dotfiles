# ~/.config/zsh/options.zsh - Options Zsh et historique

# --- Historique ---
HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history"
HISTSIZE=10000
SAVEHIST=10000

# Créer le dossier si nécessaire
[[ -d "${HISTFILE:h}" ]] || mkdir -p "${HISTFILE:h}"

setopt HIST_IGNORE_DUPS       # Pas de doublons consécutifs
setopt HIST_IGNORE_ALL_DUPS   # Supprime les anciens doublons
setopt HIST_IGNORE_SPACE      # Ignore les commandes préfixées d'un espace
setopt HIST_REDUCE_BLANKS     # Supprime les espaces superflus
setopt SHARE_HISTORY          # Partage l'historique entre les sessions
setopt APPEND_HISTORY         # Ajoute au lieu de réécrire
setopt INC_APPEND_HISTORY     # Écrit immédiatement, pas à la fermeture

# --- Navigation et complétion ---
setopt AUTO_CD                # cd implicite (tape un nom de dossier)
setopt AUTO_PUSHD             # Empile automatiquement les répertoires
setopt PUSHD_IGNORE_DUPS      # Pas de doublons dans la pile
setopt PUSHD_SILENT           # Pas d'affichage après pushd/popd

# --- Globbing ---
setopt EXTENDED_GLOB          # Globbing étendu (#, ~, ^)
setopt NO_CASE_GLOB           # Globbing insensible à la casse

# --- Correction ---
setopt CORRECT                # Correction des commandes
setopt NO_CORRECT_ALL         # Mais pas des arguments

# --- Sécurité ---
setopt NO_CLOBBER             # Empêche l'écrasement accidentel avec >
                              # Utiliser >| pour forcer
