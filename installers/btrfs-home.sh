#!/bin/bash

# Check if home config already exists
if sudo snapper list-configs | grep -q "^home "; then
    echo "Snapper home config already exists, skipping."
else
    # Create snapper config for /home
    sudo snapper -c home create-config /home
    echo "Created snapper config for /home"
fi

# Disable timeline snapshots for home config
sudo snapper -c home set-config "TIMELINE_CREATE=no"

echo "btrfs home config created with timeline snapshots disabled."
