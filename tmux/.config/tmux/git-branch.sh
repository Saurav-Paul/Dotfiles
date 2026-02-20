#!/usr/bin/env bash
# Get git branch for the active pane's working directory
# Includes powerline styling — outputs nothing when not in a git repo

pane_path=$(tmux display-message -p '#{pane_current_path}')
branch=$(git -C "$pane_path" rev-parse --abbrev-ref HEAD 2>/dev/null)

if [ -n "$branch" ]; then
  echo "#[fg=#b4befe]#[bg=#b4befe,fg=#1e1e2e,bold]  $branch #[bg=#1e1e2e,fg=#b4befe]"
fi
