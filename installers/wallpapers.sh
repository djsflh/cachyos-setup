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

# ── Configure KDE slideshow wallpaper ─────────────────────────────
PLASMA_CONFIG="$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"

if [[ ! -f "$PLASMA_CONFIG" ]]; then
    echo "  ✘ WARNING: $PLASMA_CONFIG not found. Open KDE desktop once and re-run."
else
    echo "  → Configuring KDE slideshow wallpaper..."

    # Find the line number of [Containments][43]
    SECTION_LINE=$(grep -n '^\[Containments\]\[43\]$' "$PLASMA_CONFIG" | head -1 | cut -d: -f1)
    
    if [[ -n "$SECTION_LINE" ]]; then
        # Find the next wallpaperplugin line after that section
        PLUGIN_LINE=$(tail -n +"$SECTION_LINE" "$PLASMA_CONFIG" | grep -n 'wallpaperplugin=' | head -1 | cut -d: -f1)
        ACTUAL_LINE=$(( SECTION_LINE + PLUGIN_LINE - 1 ))
        
        # Replace only that specific line
        sed -i "${ACTUAL_LINE}s/wallpaperplugin=org\.kde\.image/wallpaperplugin=org.kde.slideshow/" "$PLASMA_CONFIG"
        echo "  ✔ wallpaperplugin updated on line $ACTUAL_LINE"
    else
        echo "  ✘ Could not find [Containments][43] section"
    fi

    # Append slideshow config sections
    cat >> "$PLASMA_CONFIG" <<EOF

[Containments][43][ConfigDialog]
DialogHeight=630
DialogWidth=810

[Containments][43][Wallpaper][org.kde.slideshow][General]
FillMode=1
SlideInterval=120
SlidePaths=/usr/share/wallpapers/,$WALLPAPER_DEST/
EOF

    echo "  ✔ KDE slideshow config written"

    # Reload KDE Plasma to apply changes
    systemctl --user restart plasma-plasmashell.service
    
fi

echo
echo "Wallpaper setup complete."
