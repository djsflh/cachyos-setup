#!/bin/bash

#https://wiki.cachyos.org/virtualization/qemu_and_vmm_setup/

run_quiet "Installing qemu-full" sudo pacman -Sy --noconfirm qemu-full >> "$LOGFILE" 2>&1
run_quiet "Installing virt-manager" sudo pacman -Sy --noconfirm virt-manager >> "$LOGFILE" 2>&1
run_quiet "Installing swtpm" sudo pacman -Sy --noconfirm swtpm >> "$LOGFILE" 2>&1

# Force libvirt to use iptables
echo "Force libvirt to use iptables" 
echo ""
echo 'firewall_backend = "iptables"' | sudo tee -a /etc/libvirt/network.conf
echo ""
echo ""

# This will add the user to the "libvirt" group so they can use it:
echo "Add the user to the "libvirt" group so they can use it" 
echo ""
sudo usermod -aG libvirt "$USER"
echo ""
echo ""

# LXC backend (optional, for linux containers, enabling both backends does not conflict):
echo "Enabling LXC backend" 
echo ""
sudo systemctl enable --now libvirtd.service
echo ""
echo ""

# QEMU backend (for VMs):
echo "Enabling LXC backend" 
echo ""
sudo systemctl enable --now libvirtd.socket
echo ""
echo ""

# This will bring Internet up in a VM whenever one starts:
echo "Bring Internet up in a VM whenever one starts" 
echo ""
sudo virsh net-autostart default
echo ""
echo ""

# And to enable the entire VM network to have unfettered transit: (You should consider if you need more granular firewall rules based on your use case and security posture)
echo "Allowing VM network traffic through UFW" 
echo ""
sudo ufw route allow from 192.168.122.0/24
echo ""
echo ""

echo "QEMU installed. Log out and back in for group changes to take effect."
