#!/usr/bin/env bash
# Fuzzy session switcher with kill, rename, and create actions

current=$(tmux display-message -p '#{session_name}')

selected=$({
  tmux list-sessions -F "#{session_name}  (#{session_windows} windows)" \
    | grep "^${current} "
  tmux list-sessions -F "#{session_name}  (#{session_windows} windows)" \
    | grep -v "^${current} "
} | fzf-tmux -p 60%,40% --reverse \
    --prompt='Session: ' \
    --header="ctrl-n:new  ctrl-r:rename  ctrl-x:kill" \
    --expect='ctrl-x,ctrl-r,ctrl-n') || exit 0

key=$(echo "$selected" | head -1)
session=$(echo "$selected" | tail -1 | awk '{print $1}')

case "$key" in
  ctrl-x)
    if [[ -z "$session" ]]; then
      :
    elif [[ "$session" == "$current" ]]; then
      tmux display-message "Cannot kill the current session"
    else
      tmux kill-session -t "$session"
      tmux display-message "Killed session: $session"
    fi
    ;;
  ctrl-r)
    if [[ -n "$session" ]]; then
      name=$(printf '' | fzf-tmux -p 40%,20% --reverse --print-query \
        --prompt="Rename to: " \
        --header="Renaming: $session" | head -1) || true
      if [[ -n "$name" ]]; then
        tmux rename-session -t "$session" "$name"
      fi
    fi
    ;;
  ctrl-n)
    name=$(printf '' | fzf-tmux -p 40%,20% --reverse --print-query \
      --prompt="New session name: " | head -1) || true
    if [[ -n "$name" ]]; then
      tmux new-session -d -s "$name"
      tmux switch-client -t "$name"
    fi
    ;;
  *)
    if [[ -n "$session" ]]; then
      tmux switch-client -t "$session"
    fi
    ;;
esac

exit 0
