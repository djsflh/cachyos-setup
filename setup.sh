#!/bin/bash
set -e

REPO_CLONE="https://github.com/djsflh/cachyos-setup.git"
INSTALL_DIR="$HOME/cachyos-setup"

# ── Default: all enabled ──────────────────────────────────────────
RUN_QEMU=false
RUN_NANO=false
RUN_SSH=false
RUN_UFW=false
RUN_BTRFS=false
RUN_WALLPAPERS=false
RUN_SCRIPTS=false
RUN_VM_RESTORE=false   # off by default — only run when you want it

# ── Interactive menu ──────────────────────────────────────────────
toggle() {
    local var=$1
    eval "val=\$$var"
    if $val; then eval "$var=false"; else eval "$var=true"; fi
}

show_menu() {
    clear
    echo "╔══════════════════════════════════════╗"
    echo "║        CachyOS Setup Installer       ║"
    echo "╠══════════════════════════════════════╣"
    echo "║  Toggle items on/off, then press R   ║"
    echo "╠══════════════════════════════════════╣"
    printf "║  [1] QEMU/KVM            %s  ║\n" "$($RUN_QEMU && echo '✔ ON ' || echo '✘ OFF')"
    printf "║  [2] Nano syntax         %s  ║\n" "$($RUN_NANO && echo '✔ ON ' || echo '✘ OFF')"
    printf "║  [3] SSH                 %s  ║\n" "$($RUN_SSH && echo '✔ ON ' || echo '✘ OFF')"
    printf "║  [4] UFW firewall        %s  ║\n" "$($RUN_UFW && echo '✔ ON ' || echo '✘ OFF')"
    printf "║  [5] btrfs home config   %s  ║\n" "$($RUN_BTRFS && echo '✔ ON ' || echo '✘ OFF')"
    printf "║  [6] Wallpapers          %s  ║\n" "$($RUN_WALLPAPERS && echo '✔ ON ' || echo '✘ OFF')"
    printf "║  [7] Python scripts      %s  ║\n" "$($RUN_SCRIPTS && echo '✔ ON ' || echo '✘ OFF')"
    printf "║  [8] Restore VM          %s  ║\n" "$($RUN_VM_RESTORE && echo '✔ ON ' || echo '✘ OFF')"
    echo "╠══════════════════════════════════════╣"
    echo "║  [R] Run setup                       ║"
    echo "║  [Q] Quit                            ║"
    echo "╚══════════════════════════════════════╝"
    echo ""
    read -rp "Choice: " choice </dev/tty

    case "${choice^^}" in
        1) toggle RUN_QEMU ;;
        2) toggle RUN_NANO ;;
        3) toggle RUN_SSH ;;
        4) toggle RUN_UFW ;;
        5) toggle RUN_BTRFS ;;
        6) toggle RUN_WALLPAPERS ;;
        7) toggle RUN_SCRIPTS ;;
        8) toggle RUN_VM_RESTORE ;;
        R) return 0 ;;
        Q) echo "Aborted."; exit 0 ;;
        *) echo "Invalid choice." ;;
    esac

    show_menu  # loop back
}

show_menu

# ── Git setup ─────────────────────────────────────────────────────
echo ""
echo "=== Starting CachyOS Setup ==="

if ! command -v git &>/dev/null; then
    sudo pacman -Sy --noconfirm git
fi

if [ ! -d "$INSTALL_DIR" ]; then
    git clone "$REPO_CLONE" "$INSTALL_DIR"
else
    echo "Repo already exists, pulling latest..."
    git -C "$INSTALL_DIR" pull
fi

cd "$INSTALL_DIR"

# ── Run selected installers ───────────────────────────────────────
$RUN_QEMU        && bash installers/qemu.sh
$RUN_NANO        && bash installers/nano-syntax.sh
$RUN_SSH         && bash installers/ssh.sh
$RUN_UFW         && bash installers/ufw.sh
$RUN_BTRFS       && bash installers/btrfs-home.sh
$RUN_WALLPAPERS  && bash installers/wallpapers.sh
$RUN_VM_RESTORE  && bash vms/restore-vm.sh

if $RUN_SCRIPTS; then
    mkdir -p "$HOME/bin"
    cp "$INSTALL_DIR/scripts/"*.py "$HOME/bin/" 2>/dev/null || true
    cp "$INSTALL_DIR/scripts/"*.sh "$HOME/bin/" 2>/dev/null || true
    chmod +x "$HOME/bin/"*
    grep -q 'fish_add_path $HOME/bin' "$HOME/.config/fish/config.fish" 2>/dev/null || \
        echo 'fish_add_path $HOME/bin' >> "$HOME/.config/fish/config.fish"
    echo "Scripts copied to ~/bin"
fi

echo ""
echo "=== Setup Complete ==="
