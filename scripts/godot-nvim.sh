#!/usr/bin/env bash
set -e

export PATH="$HOME/.local/bin:$HOME/.local/kitty.app/bin:/usr/local/bin:/opt/kitty.app/bin:$PATH"
KITTY="$(command -v kitty)"
if [ -z "$KITTY" ]; then
  echo "kitty not found in PATH" >&2
  exit 1
fi

NVIM_SOCK="/tmp/godot.pipe"
file="$1"
line="${2:-1}"
col="${3:-1}"

KITTY_SOCK="$(ls -t /tmp/kitty-instance-* 2>/dev/null | head -n1)"

nvim_alive=false
if [ -S "$NVIM_SOCK" ] && nvim --server "$NVIM_SOCK" --remote-expr "1" >/dev/null 2>&1; then
  nvim_alive=true
fi

if [ "$nvim_alive" = true ]; then
  nvim --server "$NVIM_SOCK" --remote-send "<C-\\><C-n>:e ${file}<CR>:call cursor(${line},${col})<CR>"
elif [ -n "$KITTY_SOCK" ] && [ -S "$KITTY_SOCK" ]; then
  "$KITTY" @ --to "unix:$KITTY_SOCK" launch --type=tab --title=nvim \
    nvim --listen "$NVIM_SOCK" "${file}" "+call cursor(${line},${col})"
else
  rm -f "$NVIM_SOCK"
  "$KITTY" nvim --listen "$NVIM_SOCK" "${file}" "+call cursor(${line},${col})" &
fi
