#!/bin/bash

# Synchronize scripts from cachyos-setup/scripts to ~/.local/bin with a "-git" suffix

SOURCE_DIR="cachyos-setup/scripts"
DEST_DIR="~/.local/bin"

# Create destination directory if it doesn't exist
mkdir -p "$DEST_DIR"

# Synchronize bash scripts
for script in "$SOURCE_DIR"/*.sh; do
    if [[ -f "$script" ]]; then
        cp "$script" "$DEST_DIR/$(basename "$script" .sh)-git.sh"
    fi
done

# Synchronize Python scripts
for script in "$SOURCE_DIR"/*.py; do
    if [[ -f "$script" ]]; then
        cp "$script" "$DEST_DIR/$(basename "$script" .py)-git.py"
    fi
done

# Make new scripts executable
chmod +x "$DEST_DIR/*-git"