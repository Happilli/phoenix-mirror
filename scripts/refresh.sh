#!/bin/bash
set -u

CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}"
RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp}"

cache_dirs=(
  "glycin"
  "gegl-0.4"
  "gtk-4.0"
  "babl"
  "thumbnails"
  "ImageMagick"
  "gstreamer-1.0"
  "mesa_shader_cache"
  "QtProject"
  "quickshell"
  "paru"
  "pip"
  "pipx"
  "fontconfig"
  "mesa_shader_cache_db"
)

for dir in "${cache_dirs[@]}"; do
  rm -rf "${CACHE_DIR:?}/$dir"
done

find "$CACHE_DIR" -maxdepth 1 -type f -name "event-*" -delete
find "$CACHE_DIR" -maxdepth 1 -type d -name "qtshadercache*" -exec rm -rf {} +
find "$CACHE_DIR" -maxdepth 1 -type d -name "umu*" -exec rm -rf {} +

rm -rf "$RUNTIME_DIR/clipsh"
rm -f "$RUNTIME_DIR"/phoenix-capture-*.bmp
find "$RUNTIME_DIR" -maxdepth 1 -type f -name "phoenix-shot-*" -mmin +10 -delete

rm -rf "$HOME/.local/share/Trash/files/"* "$HOME/.local/share/Trash/info/"*

shopt -s nullglob
for f in "$HOME"/.zcompdump-*; do
  rm -f "$f"
done
shopt -u nullglob

rm -f "$HOME/.wget-hsts"

find /tmp -maxdepth 1 -mindepth 1 -user "$USER" -type f -mtime +1 -delete 2>/dev/null

journalctl --user --vacuum-time=1d >/dev/null 2>&1

notify-send -a "Refresh" "Caches cleared" 2>/dev/null
