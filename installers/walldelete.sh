#!/bin/bash
set -e

BIN_DIR="$HOME/.local/bin"
if [[ ! -d "$BIN_DIR" ]]; then
    mkdir -p "$BIN_DIR"
    echo "===Created directory: $BIN_DIR==="
else
    echo "===Directory already exists: $BIN_DIR==="
fi

cat > "$HOME/.local/bin/walldelete" << 'EOF'
#!/bin/bash

# Get current wallpaper path
WALLPAPER=$(busctl --user call org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell wallpaper u 0 | grep -o 'Image" s "file://[^"]*' | sed 's|Image" s "file://||' | sed 's|"||g')

rm "$WALLPAPER"
echo "Deleted $WALLPAPER."
EOF

chmod +x "$HOME/.local/bin/walldelete"

# install .desktop application to ~/.local/share/applications/
APP_DIR="$HOME/.local/share/applications"

if [[ ! -d "$APP_DIR" ]]; then
    mkdir -p "$APP_DIR"
    echo "===Created directory: $APP_DIR==="
else
    echo "===Directory already exists: $APP_DIR==="
fi

cat > "$APP_DIR/Delete Current Wallpaper.desktop" << 'EOF'
[Desktop Entry]
Name=Delete Current Wallpaper
Comment=Delete the current KDE Plasma wallpaper
Exec=$HOME/.local/bin/walldelete
Icon=user-trash
Terminal=false
Type=Application
Categories=Utility;
EOF

chmod +x "$APP_DIR/Delete Current Wallpaper.desktop"
echo "===Created desktop entry for Delete Current Wallpaper==="

CONFIG="$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc" 
BACKUP="$CONFIG.bak"

if [ -f "$CONFIG" ]; then
    cp "$CONFIG" "$BACKUP"
    echo "===Backup created: $BACKUP==="
    # Find the launchers line and append the new entry if not already present
    if grep -q "launchers=" "$CONFIG"; then
        if ! grep -q "Delete Current Wallpaper.desktop" "$CONFIG"; then
            sed -i '/launchers=/ s|$|,applications:Delete Current Wallpaper.desktop|' "$CONFIG"
            echo "===Added launcher to Plasma Task Manager.==="
        else
            echo "===Delete Current Wallpaper' launcher already exists in Plasma Task Manager.==="
        fi
    else
        echo "===Warning: Could not find launchers= line.==="
    fi
else
    echo "===Warning: plasma-org.kde.plasma.desktop-appletsrc not found.==="
fi
echo

# Add Keyboard Shortcut Alt + D
CONFIG_KGLOBAL="$HOME/.config/kglobalshortcutsrc"
BACKUP_KGLOBAL="$CONFIG_KGLOBAL.bak"

if [ -f "$CONFIG_KGLOBAL" ]; then
    cp "$CONFIG_KGLOBAL" "$BACKUP_KGLOBAL"
    echo "===Backup created: $BACKUP_KGLOBAL==="
fi

if ! command -v kwriteconfig5 &>/dev/null; then
    sudo pacman -S --noconfirm kde-cli-tools
fi

kwriteconfig5 --file "$CONFIG_KGLOBAL" --group "Delete Current Wallpaper.desktop" --key "_k_friendly_name" "Delete Current Wallpaper"
kwriteconfig5 --file "$CONFIG_KGLOBAL" --group "Delete Current Wallpaper.desktop" --key "_launch" "Alt+D,none,$HOME/.local/bin/walldelete"

echo "===Added global keyboard shortcut: Alt + D to delete current wallpaper.==="

echo "=== Delete Current Wallpaper installed successfully! Restart Plasma to apply changes ==="
