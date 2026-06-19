# Brewfile — the single source of truth for what this machine needs.
# Install everything with:  brew bundle --file ~/Desktop/Projects/dotfiles/Brewfile
# (bootstrap.sh runs this for you on a fresh machine.)
#
# Add a tool here, run `brew bundle`, and it's installed. Remove a line and run
# `brew bundle cleanup` to see what could be uninstalled.

# ── Core dotfiles tooling ────────────────────────────────────────────────────
brew "stow"                     # symlink manager — links these dotfiles into $HOME
brew "starship"                 # fast, modern shell prompt

# ── Shell experience ─────────────────────────────────────────────────────────
brew "zsh-autosuggestions"      # fish-style "ghost text" suggestions as you type
brew "zsh-syntax-highlighting"  # colors commands green/red as you type them

# ── Dev tooling ──────────────────────────────────────────────────────────────
brew "gh"                       # GitHub CLI (PRs, issues, auth) — Go binary, not tied to Node
brew "oxlint"                   # fast JS/TS linter (also usable per-project as a devDependency)

# ── Modern CLI quality-of-life replacements ──────────────────────────────────
brew "ripgrep"                  # rg  — fast grep that respects .gitignore
brew "fd"                       # fd  — friendly, fast find
brew "fzf"                      # fuzzy finder (Ctrl-R history, Ctrl-T file picker)
brew "bat"                      # cat with syntax highlighting + git markers
brew "eza"                      # modern ls (colors, icons, git, --tree)
brew "zoxide"                   # smarter cd that learns your habits
