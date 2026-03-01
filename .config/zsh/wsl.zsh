# ~/.config/zsh/wsl.zsh - Configuration spécifique à WSL
# Chargé conditionnellement si WSL est détecté

# --- VS Code ---
export PATH="$PATH:/mnt/c/Users/chauv/AppData/Local/Programs/Microsoft VS Code/bin"

# --- Docker Desktop ---
export PATH="$PATH:/mnt/c/Program Files/Docker/Docker/resources/bin"

# --- Alias outils Windows ---
alias explorer="/mnt/c/Windows/explorer.exe"
alias powershell="/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe"
alias clip="/mnt/c/Windows/System32/clip.exe"
alias open="explorer"  # Habitude macOS/Linux

# --- Clipboard bidirectionnel ---
# Copier vers le clipboard Windows depuis un pipe : echo "test" | wcopy
alias wcopy="clip"
alias wpaste="powershell -command 'Get-Clipboard'"

# --- Navigateur par défaut (pour les outils CLI qui ouvrent des URLs) ---
export BROWSER="wslview"
