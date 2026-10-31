#!/bin/sh
out="${XDG_RUNTIME_DIR:-/tmp}/phoenix-picker-result"
rm -f "$out"
exec 2>/dev/null
qs -p "${0%/*}/../picker.qml" >/dev/null
if [ -f "$out" ]; then
    printf '%s\n' "$(cat "$out")"
    rm -f "$out"
fi
