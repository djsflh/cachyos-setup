#!/bin/bash
echo "--- Configuring fish aliases ---"

FISH_CONFIG="$HOME/.config/fish/config.fish"
mkdir -p "$HOME/.config/fish"

# git push shortcut
fish -c 'alias --save gitpush="git add -A && git commit -m (read -P \"Commit message: \") && git push"' 2>/dev/null

# setup re-run alias
fish -c "alias --save setup='curl -s \"https://raw.githubusercontent.com/djsflh/cachyos-setup/main/setup.sh?\$(date +%s)\" | bash'" 2>/dev/null

echo "Fish aliases saved:"
echo "  gitpush  → stages, commits, and pushes"
echo "  setup    → re-runs the cachyos setup script"
