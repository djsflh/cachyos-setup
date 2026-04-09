#!/bin/bash
echo "--- Configuring sudo timeout ---"

SUDOERS_FILE="/etc/sudoers.d/timeout"

if sudo test -f "$SUDOERS_FILE"; then
    echo "  sudo timeout already configured, skipping."
else
    echo "Defaults        timestamp_timeout=30" | sudo tee "$SUDOERS_FILE" > /dev/null
    sudo chmod 440 "$SUDOERS_FILE"
    
    # Validate the file is syntactically correct
    if sudo visudo -cf "$SUDOERS_FILE"; then
        echo "  ✔ sudo timeout set to 30 minutes"
    else
        echo "  ✘ sudoers syntax error — removing file"
        sudo rm "$SUDOERS_FILE"
    fi
fi
