#!/bin/sh
dir="${XDG_RUNTIME_DIR:-/tmp}"
out="$dir/phoenix-picker-result"
exec 2>/dev/null
rm -f "$out"
printf '%s' "$XDPH_WINDOW_SHARING_LIST" > "$dir/phoenix-picker-list"
qs -p "$HOME/.config/quickshell/phoenix" ipc call picker toggle || exit 1
until [ -e "$out" ]; do sleep 0.1; done
res=$(cat "$out")
rm -f "$out"
[ -n "$res" ] && printf '%s\n' "$res"
exit 0
