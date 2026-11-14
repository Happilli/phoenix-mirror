#!/bin/sh
ryuctl="ryuctl"
dir="${XDG_RUNTIME_DIR:-/tmp}"
out="$dir/phoenix-picker-result"
log="$dir/picker-debug.log"
echo "$(date +%T.%N) start pid=$$ parent=$(ps -o comm= -p $PPID)" >> "$log"
exec 2>/dev/null
rm -f "$out"
mkfifo "$out" || exit 1
trap 'rm -f "$out"' EXIT
"$ryuctl" call picker toggle || exit 1
res=$(cat "$out")
echo "$(date +%T.%N) result=[$res]" >> "$log"
[ -n "$res" ] && printf '%s\n' "$res"
exit 0
