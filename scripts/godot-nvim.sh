#!/usr/bin/env bash
set -e

# Common Kitty install locations across machines
export PATH="$HOME/.local/bin:$HOME/.local/kitty.app/bin:/usr/local/bin:/opt/kitty.app/bin:$PATH"

KITTY="$(command -v kitty)"
if [ -z "$KITTY" ]; then
  echo "kitty not found in PATH" >&2
  exit 1
fi

SOCK="/tmp/godot.pipe"
file="$1"
line="${2:-1}"
col="${3:-1}"

if [ -S "$SOCK" ]; then
  nvim --server "$SOCK" --remote-send "<C-\\><C-n>:e ${file}<CR>:call cursor(${line},${col})<CR>"
else
  "$KITTY" nvim --listen "$SOCK" "${file}" "+call cursor(${line},${col})" &
fi
