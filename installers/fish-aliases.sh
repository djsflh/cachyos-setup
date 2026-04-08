#!/bin/bash

echo
echo "Adding aliases to ~/.config/fish/functions/"
echo

fish -c '
    if not functions -q gitpush
        alias --save gitpush="git add -A && git commit -m (read -P \"Commit message: \") && git push"
    end

    if not functions -q setup
        alias --save setup="curl -s \"https://raw.githubusercontent.com/djsflh/cachyos-setup/main/setup.sh?\$(date +%s)\" | bash"
    end

    if not functions -q servermode
        alias --save servermode="sudo systemctl isolate multi-user.target"
    end

    if not functions -q desktopmode
        alias --save desktopmode="sudo systemctl isolate graphical.target"
    end
' 2>/dev/null

fish -c "source ~/.config/fish/config.fish"
