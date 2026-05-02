#!/bin/bash

# Pull the wallpapers submodule
git -C "$HOME/cachyos-setup" submodule update --init --recursive --progress wallpapers

WALLPAPER_SRC="$HOME/cachyos-setup/wallpapers"
WALLPAPER_DEST="$HOME/Pictures/wallpapers"

# Copy wallpapers
if [[ ! -d "$WALLPAPER_DEST" ]]; then
    mkdir -p "$WALLPAPER_DEST"
    echo "===Created directory: $WALLPAPER_DEST==="
else
    echo "===Directory already exists: $WALLPAPER_DEST==="
fi

find "$WALLPAPER_SRC" -type f ! -name "*.md" -exec cp {} "$WALLPAPER_DEST/" \;
echo "Wallpapers copied to $WALLPAPER_DEST"

# ── Configure KDE slideshow wallpaper ─────────────────────────────
# Steps: 
# 1. Replace line wallpaperplugin=org.kde.image with wallpaperplugin=org.kde.slideshow in [Containments][43] section of plasma-org.kde.plasma.desktop-appletsrc
# 2. Append slideshow config sections to plasma-org.kde.plasma.desktop-appletsrc at the end of the file

PLASMA_CONFIG="$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"


if [[ ! -f "$PLASMA_CONFIG" ]]; then
    echo "===WARNING: $PLASMA_CONFIG not found. Open KDE desktop once and re-run.==="
else
        # Find the line number of [Containments][43]
    SECTION_LINE=$(grep -n '^\[Containments\]\[43\]$' "$PLASMA_CONFIG" | head -1 | cut -d: -f1)
    
    if [[ -n "$SECTION_LINE" ]]; then
        # Find the next wallpaperplugin line after that section
        PLUGIN_LINE=$(tail -n +"$SECTION_LINE" "$PLASMA_CONFIG" | grep -n 'wallpaperplugin=' | head -1 | cut -d: -f1)
        ACTUAL_LINE=$(( SECTION_LINE + PLUGIN_LINE - 1 ))
        
        # Replace only that specific line 
        sed -i "${ACTUAL_LINE}s/wallpaperplugin=org\.kde\.image/wallpaperplugin=org.kde.slideshow/" "$PLASMA_CONFIG"
        echo "===wallpaperplugin updated on line $ACTUAL_LINE===" # example output: wallpaperplugin updated on line 123
    else
        echo "===Could not find [Containments][43] section==="
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

    echo "===KDE slideshow config written. Restart Plasma to apply changes.==="

    
fi

echo "===Wallpaper setup complete.==="
