#!/usr/bin/env bash
# Fuzzy window switcher with kill, rename, create, and steal actions

current=$(tmux display-message -p '#{session_name}')

# Build window list grouped by session
# Target is hidden after a tab delimiter, display text comes first
build_list() {
  local sess
  for sess in $(tmux list-sessions -F '#{session_name}' | awk -v c="$current" 'BEGIN{print c} $0!=c'); do
    printf ' \033[1;34m── %s ──\033[0m\t%s\n' "$sess" "$sess"
    tmux list-windows -t "$sess" -F "#{window_index}|#{window_name}|#{pane_current_command}|#{session_name}:#{window_index}" \
      | while IFS='|' read -r idx name cmd target; do
          printf '   %s: %s  %s  \033[2m[%s]\033[0m\t%s\n' "$idx" "$name" "$cmd" "$sess" "$target"
        done
  done
}

selected=$(build_list | fzf-tmux -p 70%,50% --reverse --ansi \
    --delimiter='\t' --with-nth=1 \
    --prompt='Window: ' \
    --header="ctrl-n:new  ctrl-r:rename  ctrl-x:kill  ctrl-s:steal" \
    --expect='ctrl-x,ctrl-r,ctrl-n,ctrl-s') || exit 0

key=$(echo "$selected" | head -1)
line=$(echo "$selected" | tail -1)
target=$(echo "$line" | awk -F'\t' '{print $NF}')

[[ -z "$target" ]] && exit 0

# If a session header was selected, only Enter switches to that session
if [[ "$target" != *:* ]]; then
  [[ -z "$key" ]] && tmux switch-client -t "$target"
  exit 0
fi

case "$key" in
  ctrl-x)
    sess="${target%%:*}"
    win_count=$(tmux list-windows -t "$sess" | wc -l | tr -d ' ')
    if [[ "$win_count" -le 1 ]]; then
      tmux display-message "Cannot kill the last window in $sess"
    else
      tmux kill-window -t "$target"
      tmux display-message "Killed window: $target"
    fi
    ;;
  ctrl-r)
    name=$(printf '' | fzf-tmux -p 40%,20% --reverse --print-query \
      --prompt="Rename to: " \
      --header="Renaming: $target" | head -1) || true
    if [[ -n "$name" ]]; then
      tmux rename-window -t "$target" "$name"
    fi
    ;;
  ctrl-n)
    name=$(printf '' | fzf-tmux -p 40%,20% --reverse --print-query \
      --prompt="New window name: " | head -1) || true
    if [[ -n "$name" ]]; then
      tmux new-window -t "$current" -n "$name" -c "#{pane_current_path}"
    fi
    ;;
  ctrl-s)
    sess="${target%%:*}"
    if [[ "$sess" == "$current" ]]; then
      tmux display-message "Window already in current session"
    else
      last_idx=$(tmux list-windows -t "$current" -F '#{window_index}' | tail -1)
      tmux move-window -s "$target" -a -t "${current}:${last_idx}"
      tmux display-message "Stole $target into $current"
    fi
    ;;
  *)
    if [[ -n "$target" ]]; then
      tmux switch-client -t "$target"
    fi
    ;;
esac

exit 0
