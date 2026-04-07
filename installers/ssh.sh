#!/bin/bash
echo "--- Enabling SSH ---"

sudo pacman -Sy --noconfirm openssh

sudo systemctl enable sshd
sudo systemctl start sshd

echo "SSH enabled and started."
