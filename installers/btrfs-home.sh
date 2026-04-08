#!/bin/bash

# Check if home config already exists
    echo
if sudo snapper list-configs | grep -q "^home "; then
    echo
    echo "Snapper home config already exists, skipping."
    echo
else
    # Create snapper config for /home
    echo
    echo "Creating snapper config for /home"
    sudo snapper -c home create-config /home
    echo 
fi

# Disable timeline snapshots for home config
echo "Disabling timeline snapshots for home config"
sudo snapper -c home set-config "TIMELINE_CREATE=no"
echo
