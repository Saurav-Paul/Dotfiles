export PATH="$HOME/.local/bin:$PATH"
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

# fzf (use fd for file finding)
export FZF_DEFAULT_COMMAND="fd --hidden --follow --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type d --hidden --follow --exclude .git"
source <(fzf --zsh)

# zoxide
eval "$(zoxide init zsh --cmd cd)"

# starship
eval "$(starship init zsh)"

