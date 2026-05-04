#!/bin/bash

# Pull the wallpapers submodule
git -C "$HOME/cachyos-setup" submodule update --init --recursive --progress wallpapers

WALLPAPER_DIR="$HOME/cachyos-setup/wallpapers/wallpapers"

# ── Configure KDE slideshow wallpaper ─────────────────────────────
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
        echo "===wallpaperplugin updated on line $ACTUAL_LINE==="
    else
        echo "===Could not find [Containments][43] section==="
    fi

    # Write slideshow config using kwriteconfig6
    kwriteconfig6 --file "$PLASMA_CONFIG" \
        --group "Containments" --group "43" --group "ConfigDialog" \
        --key "DialogHeight" "630"

    kwriteconfig6 --file "$PLASMA_CONFIG" \
        --group "Containments" --group "43" --group "ConfigDialog" \
        --key "DialogWidth" "810"

    kwriteconfig6 --file "$PLASMA_CONFIG" \
        --group "Containments" --group "43" --group "Wallpaper" --group "org.kde.slideshow" --group "General" \
        --key "FillMode" "1"

    kwriteconfig6 --file "$PLASMA_CONFIG" \
        --group "Containments" --group "43" --group "Wallpaper" --group "org.kde.slideshow" --group "General" \
        --key "SlideInterval" "120"

    kwriteconfig6 --file "$PLASMA_CONFIG" \
        --group "Containments" --group "43" --group "Wallpaper" --group "org.kde.slideshow" --group "General" \
        --key "SlidePaths" "/usr/share/wallpapers/,$WALLPAPER_DIR/"

    echo "===KDE slideshow config written. Restart Plasma to apply changes.==="
fi

# ── Configure plasmalogin wallpaper ──────────────────────────────
sudo mkdir -p /var/lib/plasmalogin/wallpapers/
sudo cp "$WALLPAPER_DIR/Balcony-ja.png" /var/lib/plasmalogin/wallpapers/

PLASMALOGIN_CONF="/etc/plasmalogin.conf"

# kwriteconfig6 will create the section and key if they don't exist
sudo kwriteconfig6 --file "$PLASMALOGIN_CONF" \
    --group "Greeter" --group "Wallpaper" --group "org.kde.image" --group "General" \
    --key "Image" "file:///var/lib/plasmalogin/wallpapers/Balcony-ja.png"

echo "===plasmalogin wallpaper set in $PLASMALOGIN_CONF==="

echo "===Wallpaper setup complete.==="
