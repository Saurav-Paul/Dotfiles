# Dotfiles

Personal configuration files managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Setup

```bash
# Clone the repo
git clone git@github.com:Saurav-Paul/Dotfiles.git ~/Dotfiles
cd ~/Dotfiles

# Install stow
# Ubuntu/Debian
sudo apt install stow
# macOS
brew install stow

# Symlink configs you want (e.g. tmux)
stow tmux
```

## Packages

| Package | Creates symlink |
|---------|----------------|
| `tmux`  | `~/.tmux.conf` |
| `nvim`  | `~/.config/nvim/` |

## Adding a new config

```bash
# Example: adding zsh
mkdir -p zsh
cp ~/.zshrc zsh/.zshrc
stow zsh
```

The directory structure inside each package should mirror the path relative to `$HOME`.

## Useful commands

```bash
stow -D tmux    # remove symlinks for a package
stow -R tmux    # restow — remove + recreate symlinks (use after adding/removing files in a package)
stow -t ~ tmux  # explicitly target $HOME (needed if repo isn't directly in $HOME)
```

Editing existing files doesn't require restow — symlinks point to the real file, so changes are picked up instantly.
