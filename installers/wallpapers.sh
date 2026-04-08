#!/bin/bash

# Pull the wallpapers submodule only now that the user selected it
git -C "$HOME/cachyos-setup" submodule update --init --recursive wallpapers

WALLPAPER_SRC="$HOME/cachyos-setup/wallpapers"
WALLPAPER_DEST="$HOME/Pictures/wallpapers"

# Copy wallpapers
mkdir -p "$WALLPAPER_DEST"
find "$WALLPAPER_SRC" -type f ! -name "*.md" -exec cp {} "$WALLPAPER_DEST/" \;
echo
echo "Wallpapers copied to $WALLPAPER_DEST"

# Write the wallpaper switcher script
SWITCHER="$HOME/.local/bin/wallpaper-switcher.sh"
mkdir -p "$HOME/.local/bin"

cat > "$SWITCHER" <<'EOF'
#!/bin/bash
WALLPAPER_DIR="$HOME/Pictures/wallpapers"

# Pick a random wallpaper
WALLPAPER=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) | shuf -n 1)

if [ -z "$WALLPAPER" ]; then
    echo "No wallpapers found in $WALLPAPER_DIR"
    exit 1
fi

# Set wallpaper via KDE plasma
plasma-apply-wallpaperimage "$WALLPAPER"
EOF

chmod +x "$SWITCHER"
echo
echo "Wallpaper switcher script written to $SWITCHER"

# Write the systemd user service
mkdir -p "$HOME/.config/systemd/user"

# Get the actual UID
UID_NUM=$(id -u)

cat > "$HOME/.config/systemd/user/wallpaper-switcher.service" <<EOF
[Unit]
Description=Change desktop wallpaper
After=plasma-core.target

[Service]
Type=oneshot
ExecStart=$HOME/.local/bin/wallpaper-switcher.sh
Environment="DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/${UID_NUM}/bus"
EOF

# Write the systemd timer (every 15 minutes)
cat > "$HOME/.config/systemd/user/wallpaper-switcher.timer" <<EOF
[Unit]
Description=Change wallpaper every 15 minutes

[Timer]
OnBootSec=1min
OnUnitActiveSec=15min

[Install]
WantedBy=timers.target
EOF

# Enable and start the timer
systemctl --user daemon-reload
systemctl --user enable --now wallpaper-switcher.timer

echo
echo "Wallpaper switcher active — changes every 15 minutes."
