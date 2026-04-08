#!/bin/bash

# https://wiki.cachyos.org/virtualization/qemu_and_vmm_setup/

run_quiet "Installing qemu-full"
sudo pacman -Sy --noconfirm qemu-full >> "$LOGFILE" 2>&1
echo

run_quiet "Installing virt-manager"
sudo pacman -Sy --noconfirm virt-manager >> "$LOGFILE" 2>&1
echo

run_quiet "Installing swtpm"
sudo pacman -Sy --noconfirm swtpm >> "$LOGFILE" 2>&1
echo


echo "Force libvirt to use iptables"
echo 'firewall_backend = "iptables"' | sudo tee -a /etc/libvirt/network.conf
echo


echo "Add the user to the libvirt group so they can use it"
sudo usermod -aG libvirt "$USER"
echo


echo "Enabling LXC backend"
sudo systemctl enable --now libvirtd.service
echo


echo "Enabling QEMU backend"
sudo systemctl enable --now libvirtd.socket
echo


echo "Bring Internet up in a VM whenever one starts"
sudo virsh net-autostart default
echo


echo "Allowing VM network traffic through UFW"
sudo ufw route allow from 192.168.122.0/24
echo


echo "QEMU installed. Log out and back in for group changes to take effect."
echo
