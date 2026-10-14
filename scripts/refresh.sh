#!/bin/bash
# cleansing the caches with refresh trigger
set -u

CACHE_DIR="$HOME/.cache"
CONFIG_DIR="$HOME/.config"
HOME_DIR="$HOME"

static_dirs=(
  "glycin"
  "gegl-0.4"
  "babl"
  "thumbnails"
  "ImageMagick"
  "Microsoft"
  "mozilla"
  "net.imput.helium"
  "gstreamer-1.0"
  "mesa_shader_cache"
  "QtProject"
  "quickshell"
  "paru"
  "pip"
  "pipx"
  "lutris"
)

for dir in "${static_dirs[@]}"; do
  [ -d "$CACHE_DIR/$dir" ] && rm -rf "$CACHE_DIR/$dir"
done

find "$CACHE_DIR" -maxdepth 1 -type f -name "event-*" -delete
find "$CACHE_DIR" -maxdepth 1 -type d -name "qtshadercache*" -exec rm -rf {} +
find "$CACHE_DIR" -maxdepth 1 -type d -name "umu*" -exec rm -rf {} +

find "$CONFIG_DIR" -maxdepth 1 -type d -name "dconf*" -exec rm -rf {} +
find "$CONFIG_DIR" -maxdepth 1 -type d -name "btop*" -exec rm -rf {} +
find "$CONFIG_DIR" -maxdepth 1 -type d -name "gtk*" -exec rm -rf {} +
find "$CONFIG_DIR" -maxdepth 1 -type d -name "pulse*" -exec rm -rf {} +

rm -rf "$HOME_DIR/.local/share/Trash/files/"*
rm -rf "$HOME_DIR/.local/share/Trash/info/"*
shopt -s nullglob dotglob
for f in "$HOME_DIR"/.zcompdump-archlinux-*; do
  rm -f "$f"
done
for f in "$HOME_DIR"/.mariadb_histor*; do
  rm -f "$f"
done
shopt -u nullglob dotglob

rm -rf "$HOME_DIR/.pki"
rm -f "$HOME_DIR/.zsh_history"
rm -f "$HOME_DIR/.sqlite_history"
rm -f "$HOME_DIR/.bash_history"
rm -f "$HOME_DIR/.wget-hsts"
rm -f "$HOME_DIR/.config/mimeapps.list"

find /tmp -mindepth 1 -user "$USER" -exec rm -rf {} + 2>/dev/null
sudo journalctl --rotate
sudo journalctl --vacuum-time=1s
