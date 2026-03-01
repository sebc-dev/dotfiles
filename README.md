# Dotfiles

Configuration shell personnelle pour Ubuntu/WSL, gérée via un bare git repo.

## Installation

```bash
curl -fsSL https://raw.githubusercontent.com/sebc-dev/dotfiles/master/install.sh | bash
```

Le script est idempotent et peut être relancé sans risque.

## Ce qui est installé

### Shell

| Outil | Description |
|---|---|
| [Zsh](https://www.zsh.org/) | Shell par défaut |
| [Oh-My-Zsh](https://ohmyz.sh/) | Framework de configuration Zsh |
| [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) | Suggestions basées sur l'historique |
| [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) | Coloration syntaxique en temps réel |
| [Starship](https://starship.rs/) | Prompt rapide et personnalisable (thème Gruvbox Material) |

### Outils CLI

| Outil | Remplace | Description |
|---|---|---|
| [eza](https://github.com/eza-community/eza) | `ls` | Listing avec icônes, couleurs et intégration git |
| [bat](https://github.com/sharkdp/bat) | `cat` | Affichage avec coloration syntaxique |
| [ripgrep](https://github.com/BurntSushi/ripgrep) (`rg`) | `grep` | Recherche ultra-rapide dans les fichiers |
| [fd](https://github.com/sharkdp/fd) | `find` | Recherche de fichiers simplifiée |
| [fzf](https://github.com/junegunn/fzf) | - | Fuzzy finder interactif (thème Gruvbox Material) |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | `cd` | Navigation intelligente basée sur la fréquence |

### Runtime

| Outil | Description |
|---|---|
| [Volta](https://volta.sh/) | Gestionnaire de versions Node.js |
| [Node.js](https://nodejs.org/) | Runtime JavaScript (installé via Volta) |

### Police

| Police | Description |
|---|---|
| [JetBrains Mono Nerd Font](https://www.nerdfonts.com/) | Police monospace avec ligatures et icônes |

## Arborescence

```
~
├── .zshenv                        # Variables d'environnement (tous les shells)
├── .zshrc                         # Loader modulaire (shell interactif)
├── .zshrc.local                   # Surcharges locales (non versionné)
├── .gitconfig                     # Config git enrichie
├── .profile                       # Profil shell POSIX
├── .config/
│   ├── starship.toml              # Prompt Starship (Gruvbox Material)
│   ├── git/
│   │   └── ignore                 # Gitignore global
│   └── zsh/
│       ├── options.zsh            # Options zsh et historique
│       ├── plugins.zsh            # Oh-My-Zsh et plugins externes
│       ├── aliases.zsh            # Alias centralisés
│       ├── tools.zsh              # Init starship, zoxide, fzf
│       └── wsl.zsh                # Config WSL (chargé conditionnellement)
├── install.sh                     # Script d'installation
└── dotfiles-save.sh               # Script de sauvegarde rapide
```

## Configuration Git

Le `.gitconfig` inclut :

- `pull.rebase = true` — rebase par défaut
- `push.autoSetupRemote = true` — plus besoin de `--set-upstream`
- `fetch.prune = true` — nettoie les branches supprimées sur le remote
- `rebase.autoStash = true` — stash automatique avant rebase
- `merge.conflictstyle = zdiff3` — affiche l'ancêtre commun dans les conflits
- `diff.algorithm = histogram` — meilleur algorithme de diff
- `rerere.enabled = true` — mémorise les résolutions de conflits

### Aliases git

| Alias | Commande |
|---|---|
| `git lg` | Log compact avec graphe |
| `git last` | Dernier commit avec stats |
| `git undo` | Annule le dernier commit (soft reset) |
| `git amend` | Amend sans changer le message |
| `git wip` | Commit rapide "work in progress" |
| `git gone` | Liste les branches supprimées sur le remote |
| `git prune-branches` | Supprime les branches locales orphelines |
| `git aliases` | Liste tous les aliases configurés |

## Aliases shell

### Navigation
| Alias | Commande |
|---|---|
| `cd` | `z` (zoxide) |
| `..` | `cd ..` |
| `...` | `cd ../..` |

### Fichiers
| Alias | Commande |
|---|---|
| `ls` | `eza --icons` |
| `ll` | `eza -la --icons --git` |
| `lt` | `eza --tree --level=2` |
| `cat` | `bat --paging=never` |
| `grep` | `rg` |

### Git
| Alias | Commande |
|---|---|
| `gs` | `git status --short --branch` |
| `gl` | `git log --oneline --graph` |
| `gd` | `git diff` |
| `gds` | `git diff --staged` |

### Dotfiles
| Alias | Commande |
|---|---|
| `dotfiles` | Commande git bare repo |
| `ds` | `dotfiles status --short` |
| `da` | `dotfiles add` |
| `dc` | `dotfiles commit` |

### Docker
| Alias | Commande |
|---|---|
| `dps` | `docker ps` (format lisible) |
| `dcp` | `docker compose` |

### Utilitaires
| Alias | Commande |
|---|---|
| `reload` | Relance le shell |
| `path` | Affiche le PATH ligne par ligne |
| `myip` | Affiche l'IP publique |
| `ports` | Liste les ports ouverts |

## Sauvegarde des dotfiles

```bash
# Sauvegarder les fichiers modifiés (message auto-généré)
~/dotfiles-save.sh

# Avec message personnalisé
~/dotfiles-save.sh "ajout alias docker"

# Ajouter un nouveau fichier au tracking
~/dotfiles-save.sh --new .config/zsh/custom.zsh

# Prévisualiser sans exécuter
~/dotfiles-save.sh --dry-run
```

## WSL

Sur WSL, le module `wsl.zsh` est chargé automatiquement et configure :

- VS Code (`code`) accessible depuis le terminal
- Docker Desktop accessible depuis WSL
- Aliases : `explorer`, `powershell`, `clip`, `open`
- Clipboard bidirectionnel : `wcopy`, `wpaste`

## Notes

- **`NO_CLOBBER`** est activé : `>` ne peut pas écraser un fichier existant. Utiliser `>|` pour forcer.
- **`rm`**, **`mv`**, **`cp`** demandent confirmation (`-i`). Préfixer avec `\` pour forcer (ex: `\rm`).
- **`.zshrc.local`** permet des surcharges machine-spécifiques sans polluer le repo.
