#!/bin/sh
dir="${XDG_RUNTIME_DIR:-/tmp}"
out="$dir/phoenix-picker-result"
exec 2>/dev/null
rm -f "$out"
mkfifo "$out" || exit 1
trap 'rm -f "$out"' EXIT
qs -p "$HOME/.config/quickshell/phoenix" ipc call picker toggle "$XDPH_WINDOW_SHARING_LIST" "$XDPH_WORKSPACE_SHARING_LIST_V3" || exit 1
res=$(cat "$out")
[ -n "$res" ] && printf '%s\n' "$res"
exit 0
