# dotfiles

My personal machine setup — shell, git, Claude Code, linting, and a handful of
modern CLI tools. Managed with [GNU Stow](https://www.gnu.org/software/stow/)
(symlinks) and a [Brewfile](https://github.com/Homebrew/homebrew-bundle)
(packages).

## How it works

Each top-level folder is a **Stow "package"**: it mirrors where its files belong
in `$HOME`. Running `stow zsh` symlinks `zsh/.zshrc` → `~/.zshrc`. Because it's a
symlink, you **edit files right here in the repo** and the changes are live — no
copy step.

```
dotfiles/
├── Brewfile              # every CLI tool I install, in one list (brew bundle)
├── bootstrap.sh          # one-command setup for a fresh machine
├── zsh/.zshrc            # shell config (Starship prompt, aliases, functions)
├── starship/.config/starship.toml   # prompt appearance
├── git/.gitconfig        # git identity, aliases, sane defaults
├── git/.gitignore_global # ignored everywhere (.DS_Store, .env, …)
├── claude/.claude/       # Claude Code settings.json + statusline.sh
├── editor/.editorconfig  # global formatting defaults
└── oxlint/.oxlintrc.json # JS/TS lint config (a TEMPLATE — see below)
```

## Fresh machine setup

```sh
git clone <this-repo-url> ~/Desktop/Projects/dotfiles
cd ~/Desktop/Projects/dotfiles
./bootstrap.sh
exec zsh        # or just open a new terminal
```

`bootstrap.sh` installs Homebrew, runs `brew bundle`, backs up any existing
dotfiles to `~/.dotfiles-backup/<timestamp>/`, and stows everything.

## Day-to-day

| Task | Command |
|------|---------|
| Edit shell config | `zshrc` (alias) or edit `zsh/.zshrc` |
| Add a tool | add a line to `Brewfile`, then `brew bundle` |
| Re-link after adding a file | `stow <package>` from the repo root |
| Unlink a package | `stow -D <package>` |
| Apply changes | open a new terminal, or `exec zsh` |

## The oxlint config is a template

`oxlint/.oxlintrc.json` is **not** stowed into `$HOME` — oxlint reads its config
from the project you run it in, not your home folder. Copy it into a project:

```sh
cp ~/Desktop/Projects/dotfiles/oxlint/.oxlintrc.json .
```

Or, better for teams, add oxlint per-project and commit the config:

```sh
pnpm add -D oxlint
```

## Notes

- **Prompt:** [Starship](https://starship.rs). For the fancy glyphs, install a
  Nerd Font: `brew install --cask font-meslo-lg-nerd-font` and select it in your
  terminal. The config uses plain text so it looks fine without one.
- **Node:** managed by `nvm` (not in the Brewfile — keep using your installer).
- **Work git identity:** see the commented `includeIf` block in `git/.gitconfig`
  to use a different email under `~/Desktop/Work/`.
