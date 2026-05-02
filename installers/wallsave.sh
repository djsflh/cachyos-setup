#!/bin/bash
set -e

SAVED_DIR="$HOME/Pictures/saved"
if [[ ! -d "$SAVED_DIR" ]]; then
    mkdir -p "$SAVED_DIR"
    echo "===Created directory: $SAVED_DIR==="
else
    echo "===Directory already exists: $SAVED_DIR==="
fi

BIN_DIR="$HOME/.local/bin"
if [[ ! -d "$BIN_DIR" ]]; then
    mkdir -p "$BIN_DIR"
    echo "===Created directory: $BIN_DIR==="
else
    echo "===Directory already exists: $BIN_DIR==="
fi

cat > "$HOME/.local/bin/wallsave" << 'EOF'
#!/bin/bash

# Get current wallpaper path
WALLPAPER=$(busctl --user call org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell wallpaper u 0 | grep -o 'Image" s "file://[^"]*' | sed 's|Image" s "file://||' | sed 's|"||g')

# Get the filename from the wallpaper path
FILENAME=$(basename "$WALLPAPER")

DEST="$HOME/Pictures/saved/$FILENAME"

cp "$WALLPAPER" "$DEST" 2>/dev/null || true
echo "Saved $WALLPAPER to $DEST."
EOF

chmod +x "$HOME/.local/bin/wallsave"

# install .desktop application to ~/.local/share/applications/
APP_DIR="$HOME/.local/share/applications"

if [[ ! -d "$APP_DIR" ]]; then
    mkdir -p "$APP_DIR"
    echo "===Created directory: $APP_DIR==="
else
    echo "===Directory already exists: $APP_DIR==="
fi

cat > "$APP_DIR/Save Current Wallpaper.desktop" << 'EOF'
[Desktop Entry]
Name=Save Current Wallpaper
Comment=Save the current KDE Plasma wallpaper
Exec=$HOME/.local/bin/wallsave
Icon=preferences-desktop-wallpaper
Terminal=false
Type=Application
Categories=Utility;
EOF

chmod +x "$APP_DIR/Save Current Wallpaper.desktop"
echo "===Created desktop entry for Save Current Wallpaper==="

CONFIG="$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"
BACKUP="$CONFIG.bak"

if [ -f "$CONFIG" ]; then
    cp "$CONFIG" "$BACKUP"
    echo "===Backup created: $BACKUP==="
    # Find the launchers line and append the new entry if not already present
    if grep -q "launchers=" "$CONFIG"; then
        if ! grep -q "Save Current Wallpaper.desktop" "$CONFIG"; then
            sed -i '/launchers=/ s|$|,applications:Save Current Wallpaper.desktop|' "$CONFIG"
            echo "===Added launcher to Plasma Task Manager.==="
        else
			echo "===Save Current Wallpaper' launcher already exists in Plasma Task Manager.==="
        fi
    else
        echo "===Warning: Could not find launchers= line.==="
    fi
else
    echo "===Warning: plasma-org.kde.plasma.desktop-appletsrc not found.==="
fi
echo

# Add Keyboard Shortcut Alt + W
CONFIG_KGLOBAL="$HOME/.config/kglobalshortcutsrc"
BACKUP_KGLOBAL="$CONFIG_KGLOBAL.bak"

if [ -f "$CONFIG_KGLOBAL" ]; then
    cp "$CONFIG_KGLOBAL" "$BACKUP_KGLOBAL"
    echo "===Backup created: $BACKUP_KGLOBAL==="
fi

kwriteconfig5 --file "$CONFIG_KGLOBAL" --group "Save Current Wallpaper.desktop" --key "_k_friendly_name" "Save Current Wallpaper"
kwriteconfig5 --file "$CONFIG_KGLOBAL" --group "Save Current Wallpaper.desktop" --key "_launch" "Alt+W,none,$HOME/.local/bin/wallsave"

echo "===Added global keyboard shortcut: Alt + W to save current wallpaper.==="

echo "=== Save Current Wallpaper installed successfully! Restart Plasma to apply changes ==="
