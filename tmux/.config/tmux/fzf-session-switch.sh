#!/usr/bin/env bash
# Fuzzy session switcher: current session first, then all others

current=$(tmux display-message -p '#{session_name}')

{
  tmux list-sessions -F "#{session_name}  (#{session_windows} windows)" \
    | grep "^${current} "
  tmux list-sessions -F "#{session_name}  (#{session_windows} windows)" \
    | grep -v "^${current} "
} | fzf-tmux -p 60%,40% --reverse \
    --prompt='Switch to: ' \
    --header="Current session: $current" \
  | awk '{print $1}' \
  | xargs -I{} tmux switch-client -t '{}'
