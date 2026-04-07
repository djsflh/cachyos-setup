#!/bin/bash
echo "--- Setting up wallpapers ---"

WALLPAPER_SRC="$HOME/cachyos-setup/wallpapers"
WALLPAPER_DEST="$HOME/Pictures/Wallpapers"

mkdir -p "$WALLPAPER_DEST"
cp -r "$WALLPAPER_SRC"/. "$WALLPAPER_DEST/"
echo "Wallpapers copied to $WALLPAPER_DEST"

# Install a wallpaper switcher
# 'variety' is a good option available in AUR
if ! command -v variety &>/dev/null; then
    # Use yay or paru for AUR
    if command -v yay &>/dev/null; then
        yay -S --noconfirm variety
    elif command -v paru &>/dev/null; then
        paru -S --noconfirm variety
    else
        echo "No AUR helper found. Install variety manually for wallpaper switching."
    fi
fi

# Configure variety to use your folder and switch every 15 min
VARIETY_CONF="$HOME/.config/variety/variety.conf"
mkdir -p "$HOME/.config/variety"

if [ -f "$VARIETY_CONF" ]; then
    # Update interval to 15 minutes (900 seconds)
    sed -i 's/^change_interval\s*=.*/change_interval = 900/' "$VARIETY_CONF"
else
    cat > "$VARIETY_CONF" <<EOF
[variety]
change_interval = 900
sources = [["local", True, "$WALLPAPER_DEST"]]
EOF
fi

echo "Wallpaper switcher configured for 15-minute intervals."
