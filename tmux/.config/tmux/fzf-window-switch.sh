#!/usr/bin/env bash
# Fuzzy window switcher: current session windows first, then all others

current=$(tmux display-message -p '#{session_name}')

# Current session windows first, then the rest
{
  tmux list-windows -t "$current" -F "#{session_name}:#{window_index}  #{window_name}  #{pane_current_command}"
  tmux list-windows -a -F "#{session_name}:#{window_index}  #{window_name}  #{pane_current_command}" \
    | grep -v "^${current}:"
} | fzf-tmux -p 70%,50% --reverse \
    --prompt='Switch to: ' \
    --header="Current session: $current" \
  | awk '{print $1}' \
  | xargs -I{} tmux switch-client -t '{}'
