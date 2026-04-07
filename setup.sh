#!/bin/bash
set -e

REPO_CLONE="https://github.com/djsflh/cachyos-setup.git"
INSTALL_DIR="$HOME/cachyos-setup"
LOGFILE="$HOME/cachyos-setup-install.log"
export LOGFILE

echo "=== CachyOS Setup $(date) ===" > "$LOGFILE"
echo "Log file: $LOGFILE"
echo ""

# Usage: run_quiet "Description" command args...
run_quiet() {
    local desc="$1"
    shift
    echo -n "  → $desc... "
    echo "--- $desc ---" >> "$LOGFILE"
    if "$@" >> "$LOGFILE" 2>&1; then
        echo "✔"
        echo "  ✔ Done" >> "$LOGFILE"
    else
        echo "✘ FAILED (check $LOGFILE)"
        echo "  ✘ FAILED" >> "$LOGFILE"
    fi
}
export -f run_quiet

# ── Git setup first so we have installers.conf ────────────────────
if ! command -v git &>/dev/null; then
    sudo pacman -Sy --noconfirm git
fi

if [ ! -d "$INSTALL_DIR" ]; then
    git clone --recurse-submodules "$REPO_CLONE" "$INSTALL_DIR"
else
    echo "Repo already exists, pulling latest..."
    git -C "$INSTALL_DIR" pull
    git -C "$INSTALL_DIR" submodule update --init --recursive
fi

cd "$INSTALL_DIR"

CONF="$INSTALL_DIR/installers/installers.conf"

# ── Load installers from conf ─────────────────────────────────────
declare -a SCRIPTS LABELS STATES

while IFS='|' read -r script label default; do
    [[ -z "$script" || "$script" == \#* ]] && continue
    SCRIPTS+=("$script")
    LABELS+=("$label")
    STATES+=("$default")
done < "$CONF"

# ── Toggle helper ─────────────────────────────────────────────────
toggle() {
    local idx=$1
    [[ "${STATES[$idx]}" == "on" ]] && STATES[$idx]="off" || STATES[$idx]="on"
}

# ── Show last commit ──────────────────────────────────────────────
LAST_COMMIT=$(git -C "$INSTALL_DIR" log -1 --format="%cr: %s")

# ── Menu ──────────────────────────────────────────────────────────
show_menu() {
    clear
    echo "╔══════════════════════════════════════╗"
    echo "║        CachyOS Setup Installer       ║"
    echo "╠══════════════════════════════════════╣"
    echo "║  Toggle items on/off, then press R   ║"
    echo "╠══════════════════════════════════════╣"
    printf "║  [1] QEMU/KVM            %s ║\n" "$($RUN_QEMU && echo '✔ ON ' || echo '✘ OFF')"
    printf "║  [2] Nano syntax         %s ║\n" "$($RUN_NANO && echo '✔ ON ' || echo '✘ OFF')"
    printf "║  [3] SSH                 %s ║\n" "$($RUN_SSH && echo '✔ ON ' || echo '✘ OFF')"
    printf "║  [4] UFW firewall        %s ║\n" "$($RUN_UFW && echo '✔ ON ' || echo '✘ OFF')"
    printf "║  [5] btrfs home config   %s ║\n" "$($RUN_BTRFS && echo '✔ ON ' || echo '✘ OFF')"
    printf "║  [6] Wallpapers          %s ║\n" "$($RUN_WALLPAPERS && echo '✔ ON ' || echo '✘ OFF')"
    printf "║  [7] Python scripts      %s ║\n" "$($RUN_SCRIPTS && echo '✔ ON ' || echo '✘ OFF')"
    printf "║  [8] Restore VM          %s ║\n" "$($RUN_VM_RESTORE && echo '✔ ON ' || echo '✘ OFF')"
    echo "╠══════════════════════════════════════╣"
    echo "║  [R] Run setup                       ║"
    echo "║  [Q] Quit                            ║"
    echo "╚══════════════════════════════════════╝"
    echo ""
    echo "  Last update: $LAST_COMMIT"
    echo ""
    read -rp "Choice: " choice </dev/tty

    case "${choice^^}" in
        R) return 0 ;;
        Q) echo "Aborted."; exit 0 ;;
        ''|*[!0-9]*) show_menu ;;
        *)
            local idx=$((choice - 1))
            if [[ $idx -ge 0 && $idx -lt ${#SCRIPTS[@]} ]]; then
                toggle "$idx"
            fi
            show_menu
            ;;
    esac
}

show_menu

# ── Run selected installers ───────────────────────────────────────
echo ""
echo "=== Starting CachyOS Setup ==="

for i in "${!SCRIPTS[@]}"; do
    if [[ "${STATES[$i]}" == "on" ]]; then
        local_script="$INSTALL_DIR/installers/${SCRIPTS[$i]}"
        if [[ -f "$local_script" ]]; then
            echo ""
            echo "--- Running: ${LABELS[$i]} ---"
            bash "$local_script"
        else
            echo "WARNING: $local_script not found, skipping." | tee -a "$LOGFILE"
        fi
    fi
done

# ── Shell config ──────────────────────────────────────────────────
echo ""
echo "--- Configuring fish aliases ---"
bash "$INSTALL_DIR/installers/fish-aliases.sh"

echo ""
echo "=== Setup Complete ==="
