#!/bin/bash

SOURCE_DIR="$HOME/cachyos-setup/scripts"
DEST_DIR="$HOME/.local/bin"

if [[ ! -d "$DEST_DIR" ]]; then
    mkdir -p "$DEST_DIR"
    echo "===Created directory: $DEST_DIR==="
else
    echo "===Directory already exists: $DEST_DIR==="
fi

# ── Helper: prompt before overwrite ──────────────────────────────
confirm_overwrite() {
    local dest="$1"
    if [[ -f "$dest" ]]; then
        read -rp "  Overwrite $(basename "$dest")? (y/N): " answer </dev/tty
        [[ "${answer^^}" == "Y" ]] && return 0 || return 1
    fi
    return 0  # file doesn't exist, no prompt needed
}

declare -a EXPECTED_DEST_FILES # declare an array to hold expected filenames

# ── Copy scripts ──────────────────────────────────────────────────
for script in "$SOURCE_DIR"/*; do
    [[ -f "$script" ]] || continue

    filename=$(basename "$script")
    ext="${filename##*.}"

    # Determine destination filename
    if [[ "$filename" == "$ext" ]]; then
        # No extension
        dest_name="${filename}-git"
    else
        dest_name="${filename%.*}-git.${ext}"
    fi

    dest="$DEST_DIR/$dest_name"
    EXPECTED_DEST_FILES+=("$dest_name")

    if confirm_overwrite "$dest"; then
        cp "$script" "$dest"
        chmod +x "$dest"
        echo "===$filename → $dest_name==="
    else
        echo "===Skipped $filename==="
    fi
done

# ── Remove scripts no longer in repo ─────────────────────────────
for existing in "$DEST_DIR"/*-git "$DEST_DIR"/*-git.*; do
    [[ -f "$existing" ]] || continue
    existing_name=$(basename "$existing")

    # Check if this file is in our expected list
    found=false
    for expected in "${EXPECTED_DEST_FILES[@]}"; do
        [[ "$expected" == "$existing_name" ]] && found=true && break
    done

    if [[ "$found" == false ]]; then
        read -rp "  Remove stale script $existing_name? (y/N): " answer </dev/tty
        if [[ "${answer^^}" == "Y" ]]; then
            rm "$existing"
            echo "===Removed $existing_name==="
        else
            echo "===Kept $existing_name==="
        fi
    fi
done

echo "===Script sync complete.==="
