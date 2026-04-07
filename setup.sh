#!/bin/bash
set -e

REPO="https://raw.githubusercontent.com/djsflh/cachyos-setup/main"
REPO_CLONE="https://github.com/djsflh/cachyos-setup.git"
INSTALL_DIR="$HOME/cachyos-setup"

echo "=== CachyOS Setup Starting ==="

# Install git if missing
if ! command -v git &>/dev/null; then
    sudo pacman -Sy --noconfirm git
fi

# Clone the repo
if [ ! -d "$INSTALL_DIR" ]; then
    git clone "$REPO_CLONE" "$INSTALL_DIR"
else
    echo "Repo already exists, pulling latest..."
    git -C "$INSTALL_DIR" pull
fi

cd "$INSTALL_DIR"

# Run each installer
bash installers/qemu.sh
bash installers/nano-syntax.sh
bash installers/ssh.sh
bash installers/ufw.sh
bash installers/btrfs-home.sh
bash installers/wallpapers.sh
bash installers/kde-settings.sh  # run last, needs desktop running

# Copy personal scripts to ~/bin and make executable
mkdir -p "$HOME/bin"
cp "$INSTALL_DIR/scripts/"*.py "$HOME/bin/" 2>/dev/null || true
cp "$INSTALL_DIR/scripts/"*.sh "$HOME/bin/" 2>/dev/null || true
chmod +x "$HOME/bin/"*

# Make sure ~/bin is in PATH
if ! grep -q 'export PATH="$HOME/bin:$PATH"' "$HOME/.bashrc"; then
    echo 'export PATH="$HOME/bin:$PATH"' >> "$HOME/.bashrc"
fi

echo ""
echo "=== Setup Complete! ==="
echo "Your scripts are in ~/bin"
