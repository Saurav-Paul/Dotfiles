export PATH="/opt/homebrew/opt/libpq/bin:$HOME/.local/bin:$PATH"
export EDITOR="nvim"
export VISUAL="nvim"

# fnm
eval "$(fnm env --use-on-cd)"

# aliases
alias cat="bat"
alias ls="eza"
alias ll="eza -l --git"
alias la="eza -la --git"
alias lt="eza --tree --level=2"
alias td="tooldock"

# fzf (use fd for file finding)
export FZF_DEFAULT_COMMAND="fd --hidden --follow --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type d --hidden --follow --exclude .git"
source <(fzf --zsh)

# zoxide
eval "$(zoxide init zsh --cmd zi)"

# zsh-autosuggestions
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# drop
export DROP_SERVER=https://drop.sauravpaul.uk

# starship
eval "$(starship init zsh)"


# bun completions
[ -s "/Users/saurav_paul/.bun/_bun" ] && source "/Users/saurav_paul/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
