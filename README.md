# Dotfiles

Personal configuration files managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Setup

```bash
# Clone the repo
git clone git@github.com:<your-username>/Dotfiles.git ~/Dotfiles
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

## Adding a new config

```bash
# Example: adding zsh
mkdir -p zsh
cp ~/.zshrc zsh/.zshrc
stow zsh
```

The directory structure inside each package should mirror the path relative to `$HOME`.

## Removing a config

```bash
stow -D tmux   # removes the symlink
```
