#!/bin/bash
SUDOERS_TIMEOUT_FILE="/etc/sudoers.d/timeout"

if sudo test -f "$SUDOERS_TIMEOUT_FILE"; then
    echo "===Timeout file already exists, skipping.==="
else
    echo "Defaults        timestamp_timeout=30" | sudo tee "$SUDOERS_TIMEOUT_FILE" > /dev/null
    sudo chmod 440 "$SUDOERS_TIMEOUT_FILE"

    # Validate the file is syntactically correct
    if sudo visudo -cf "$SUDOERS_TIMEOUT_FILE"; then
        echo "===sudo timeout set to 30 minutes==="
    else
        echo "===sudoers syntax error — removing file==="
        sudo rm "$SUDOERS_TIMEOUT_FILE"
    fi
fi
