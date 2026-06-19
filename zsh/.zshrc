# ~/.zshrc — interactive shell config.
# Managed in ~/Desktop/Projects/dotfiles and symlinked here by GNU Stow.
# Edit it in the repo (alias: `zshrc`); changes are live in new shells.

# ── PATH ─────────────────────────────────────────────────────────────────────
# Homebrew itself is set up in ~/.zprofile (eval "$(brew shellenv)").
export PATH="$HOME/.local/bin:$HOME/Scripts:$PATH"

# ── Editor ───────────────────────────────────────────────────────────────────
export EDITOR="code --wait"
export VISUAL="$EDITOR"

# ── History ──────────────────────────────────────────────────────────────────
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY          # share history live across open terminals
setopt HIST_IGNORE_ALL_DUPS   # drop older duplicates of a command
setopt HIST_REDUCE_BLANKS     # strip superfluous whitespace
setopt INC_APPEND_HISTORY     # append as you go, not just on exit

# ── Completion ───────────────────────────────────────────────────────────────
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'   # case-insensitive

# ── Node / nvm ───────────────────────────────────────────────────────────────
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"

# ── pnpm ─────────────────────────────────────────────────────────────────────
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# ── Aliases: navigation ──────────────────────────────────────────────────────
alias zshrc="code ~/.zshrc"          # renamed from `zsh` so it stops shadowing the zsh binary
alias music="cd ~/Documents/music"
alias projects="cd ~/Desktop/Projects"
alias portfolio="cd ~/Desktop/Projects/druserkes"
alias dru="cd ~/Desktop/Dru"
alias work="cd ~/Desktop/Work"
alias desktop="cd ~/Desktop"
alias tfd='cd ~/Desktop/Work/"The Farmers Dog"/code'

# ── Aliases: git ─────────────────────────────────────────────────────────────
alias gs="git status"
alias gco="git checkout"
alias gpuo="git push --set-upstream origin"
alias gpom="git pull origin main"
# push current branch and set its upstream (was `yeet`; fixed to use && and the real branch)
alias yeet='git push -u origin "$(git branch --show-current)"'

# ── Aliases: node / dev ──────────────────────────────────────────────────────
alias i="nvm use && npm install"     # was `&` (ran in background) — fixed to `&&`
alias dev="npm start"

# ── Modern CLI replacements (installed via Brewfile; comment out any you dislike)
if command -v eza >/dev/null 2>&1; then
  alias ls="eza --group-directories-first --icons=auto"
  alias ll="eza -lah --group-directories-first --icons=auto --git"
  alias tree="eza --tree --level=2 --icons=auto"
fi
if command -v bat >/dev/null 2>&1; then
  alias cat="bat --paging=never"
  export BAT_THEME="ansi"
fi

# ── Functions ────────────────────────────────────────────────────────────────
# Pull the long-lived branches in the current repo. Adjust names per project.
pull_all() {
  for b in master preview test; do
    git checkout "$b" && git pull origin "$b"
  done
}

# Open your portfolio project in VS Code.
openPortfolio() {
  portfolio && code .
}

# Today's disk usage report.
space() {
  ~/Scripts/disk_usage_today.sh
}

# ── Tool initialisations ─────────────────────────────────────────────────────
# zoxide: smarter cd. `z <partial-dir-name>` jumps to a folder you've visited.
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"

# fzf: Ctrl-R fuzzy history search, Ctrl-T fuzzy file picker.
command -v fzf >/dev/null 2>&1 && source <(fzf --zsh) 2>/dev/null

# zsh-autosuggestions: ghost-text suggestions from history (→ to accept).
[ -f /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ] && \
  source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# Starship prompt — keep this near the end.
command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"

# zsh-syntax-highlighting MUST be the very last thing sourced.
[ -f /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && \
  source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
