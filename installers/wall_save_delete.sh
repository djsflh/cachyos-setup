#!/bin/bash
set -e

BIN_DIR="$HOME/.local/bin"
if [[ ! -d "$BIN_DIR" ]]; then
    mkdir -p "$BIN_DIR"
    echo "===Created directory: $BIN_DIR==="
else
    echo "===Directory already exists: $BIN_DIR==="
fi

APP_DIR="$HOME/.local/share/applications"
if [[ ! -d "$APP_DIR" ]]; then
    mkdir -p "$APP_DIR"
    echo "===Created directory: $APP_DIR==="
else
    echo "===Directory already exists: $APP_DIR==="
fi

# ── wallsave ──────────────────────────────────────────────────────
cat > "$BIN_DIR/wallsave" << 'EOF'
#!/bin/bash
# Get current wallpaper path
WALLPAPER=$(busctl --user call org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell wallpaper u 0 | grep -o 'Image" s "file://[^"]*' | sed 's|Image" s "file://||' | sed 's|"||g')
DEST="/mnt/share/wallpapers/saved/"
cp "$WALLPAPER" "$DEST"
EOF

chmod +x "$BIN_DIR/wallsave"
echo "===Created $BIN_DIR/wallsave==="

cat > "$APP_DIR/Save Current Wallpaper.desktop" << 'EOF'
[Desktop Entry]
Name=Save Current Wallpaper
Comment=Save the current KDE Plasma wallpaper
Exec=/bin/bash -c '$HOME/.local/bin/wallsave'
Icon=preferences-desktop-wallpaper
Terminal=false
Type=Application
Categories=Utility;
EOF

chmod +x "$APP_DIR/Save Current Wallpaper.desktop"
echo "===Created desktop entry for Save Current Wallpaper==="

# ── walldelete ────────────────────────────────────────────────────
cat > "$BIN_DIR/walldelete" << 'EOF'
#!/bin/bash
# Get current wallpaper path
WALLPAPER=$(busctl --user call org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell wallpaper u 0 | grep -o 'Image" s "file://[^"]*' | sed 's|Image" s "file://||' | sed 's|"||g')
rm "$WALLPAPER"
EOF

chmod +x "$BIN_DIR/walldelete"
echo "===Created $BIN_DIR/walldelete==="

cat > "$APP_DIR/Delete Current Wallpaper.desktop" << 'EOF'
[Desktop Entry]
Name=Delete Current Wallpaper
Comment=Delete the current KDE Plasma wallpaper
Exec=/bin/bash -c '$HOME/.local/bin/walldelete'
Icon=user-trash
Terminal=false
Type=Application
Categories=Utility;
EOF

chmod +x "$APP_DIR/Delete Current Wallpaper.desktop"
echo "===Created desktop entry for Delete Current Wallpaper==="

# ── Plasma task manager launchers ─────────────────────────────────
CONFIG="$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"
BACKUP="$CONFIG.bak"

if [[ -f "$CONFIG" ]]; then
    cp "$CONFIG" "$BACKUP"
    echo "===Backup created: $BACKUP==="

    if grep -q "launchers=" "$CONFIG"; then
        if ! grep -q "Save Current Wallpaper.desktop" "$CONFIG"; then
            sed -i '/launchers=/ s|$|,applications:Save Current Wallpaper.desktop|' "$CONFIG"
            echo "===Added Save launcher to Plasma Task Manager.==="
        else
            echo "===Save Current Wallpaper launcher already exists in Plasma Task Manager.==="
        fi

        if ! grep -q "Delete Current Wallpaper.desktop" "$CONFIG"; then
            sed -i '/launchers=/ s|$|,applications:Delete Current Wallpaper.desktop|' "$CONFIG"
            echo "===Added Delete launcher to Plasma Task Manager.==="
        else
            echo "===Delete Current Wallpaper launcher already exists in Plasma Task Manager.==="
        fi
    else
        echo "===Warning: Could not find launchers= line.==="
    fi
else
    echo "===Warning: plasma-org.kde.plasma.desktop-appletsrc not found.==="
fi

# ── Global keyboard shortcuts ─────────────────────────────────────
CONFIG_KGLOBAL="$HOME/.config/kglobalshortcutsrc"
BACKUP_KGLOBAL="$CONFIG_KGLOBAL.bak"

if [[ -f "$CONFIG_KGLOBAL" ]]; then
    cp "$CONFIG_KGLOBAL" "$BACKUP_KGLOBAL"
    echo "===Backup created: $BACKUP_KGLOBAL==="
fi

kwriteconfig6 --file "$CONFIG_KGLOBAL" --group "Save Current Wallpaper.desktop" --key "_k_friendly_name" "Save Current Wallpaper"
kwriteconfig6 --file "$CONFIG_KGLOBAL" --group "Save Current Wallpaper.desktop" --key "_launch" "Alt+W,none,$BIN_DIR/wallsave"
echo "===Added global keyboard shortcut: Alt+W to save current wallpaper.==="

kwriteconfig6 --file "$CONFIG_KGLOBAL" --group "Delete Current Wallpaper.desktop" --key "_k_friendly_name" "Delete Current Wallpaper"
kwriteconfig6 --file "$CONFIG_KGLOBAL" --group "Delete Current Wallpaper.desktop" --key "_launch" "Alt+D,none,$BIN_DIR/walldelete"
echo "===Added global keyboard shortcut: Alt+D to delete current wallpaper.==="

echo "=== Wall buttons installed successfully! Restart Plasma to apply changes ==="
