#!/usr/bin/env bash
# Rex port of ~/.config/tmux/tmux-sessionizer.sh: pick a project dir, then switch to (or create) its session.

if [[ $# -eq 1 ]]; then
    selected=$1
else
    selected=$(find ~/code/mj ~/code/work ~/.config -mindepth 1 -maxdepth 2 -type d | fzf)
fi

if [[ -z $selected ]]; then
    exit 0
fi

selected_name=$(basename "$selected" | tr . _)

session_id=$(rex ls --json | jq -r --arg n "$selected_name" \
    'first(.sessions[] | select(.label == $n) | .session_id) // empty')

if [[ -z $session_id ]]; then
    session_id=$(rex new "$selected_name" -c "$selected" --json | jq -r .session_id) || exit 1
fi

rex do session.select session_id="$session_id"
