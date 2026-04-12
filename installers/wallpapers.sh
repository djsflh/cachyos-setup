#!/bin/bash

# Pull the wallpapers submodule only now that the user selected it
git -C "$HOME/cachyos-setup" submodule update --init --recursive --progress wallpapers

WALLPAPER_SRC="$HOME/cachyos-setup/wallpapers"
WALLPAPER_DEST="$HOME/Pictures/wallpapers"

# Copy wallpapers
mkdir -p "$WALLPAPER_DEST"
find "$WALLPAPER_SRC" -type f ! -name "*.md" -exec cp {} "$WALLPAPER_DEST/" \;
echo
echo "Wallpapers copied to $WALLPAPER_DEST"

echo
echo "Wallpaper switcher active — changes every 15 minutes."
