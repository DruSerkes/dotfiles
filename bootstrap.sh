#!/usr/bin/env bash
# bootstrap.sh — set up these dotfiles on a machine.
#   1. installs Homebrew (if missing)
#   2. installs everything in the Brewfile
#   3. backs up any existing real dotfiles, then symlinks ours in with GNU Stow
#
# Safe to re-run. From the repo root:  ./bootstrap.sh

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DOTFILES_DIR"

# Packages Stow should link into $HOME.
# (oxlint is intentionally excluded — it's a per-project template; see README.)
STOW_PACKAGES=(zsh starship git claude editor)

BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

echo "▸ dotfiles dir: $DOTFILES_DIR"

# 1. Homebrew ----------------------------------------------------------------
if ! command -v brew >/dev/null 2>&1; then
  echo "▸ Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"

# 2. Brew bundle -------------------------------------------------------------
echo "▸ Installing packages from Brewfile..."
brew bundle --file="$DOTFILES_DIR/Brewfile"

# 3. Back up conflicts, then stow -------------------------------------------
# If a target already exists as a real file (not our symlink), move it aside so
# stow won't refuse. Backups land in ~/.dotfiles-backup/<timestamp>/.
back_up_if_real() {
  local target="$1"
  if [ -e "$target" ] && [ ! -L "$target" ]; then
    mkdir -p "$BACKUP_DIR"
    echo "  backing up $target -> $BACKUP_DIR/"
    mv "$target" "$BACKUP_DIR/"
  fi
}

echo "▸ Linking dotfiles with stow..."
back_up_if_real "$HOME/.zshrc"
back_up_if_real "$HOME/.gitconfig"
back_up_if_real "$HOME/.gitignore_global"
back_up_if_real "$HOME/.editorconfig"
back_up_if_real "$HOME/.config/starship.toml"
back_up_if_real "$HOME/.claude/settings.json"
back_up_if_real "$HOME/.claude/statusline.sh"

for pkg in "${STOW_PACKAGES[@]}"; do
  echo "  - stow $pkg"
  stow --target="$HOME" --restow "$pkg"
done

echo "✅ Done. Open a new terminal (or run: exec zsh)."
[ -d "$BACKUP_DIR" ] && echo "   Your old files were backed up to: $BACKUP_DIR"
