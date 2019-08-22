#!/usr/bin/env bash
set -xe

echo "deb http://download.proxmox.com/debian stretch pve-no-subscription" >> /etc/apt/sources.list.d/pmg-community.list 
echo "deb http://download.proxmox.com/debian stretch pvetest" >> /etc/apt/sources.list.d/pmg-community.list
sed -i 's/^deb/#deb/g' /etc/apt/sources.list.d/pmg-enterprise.list

DEBIAN_FRONTEND=noninteractive apt update -y
DEBIAN_FRONTEND=noninteractive apt dist-upgrade -y
DEBIAN_FRONTEND=noninteractive apt install -y qemu-guest-agent

cat > /etc/default/grub <<EOF
GRUB_DEFAULT=0
GRUB_HIDDEN_TIMEOUT=0
GRUB_HIDDEN_TIMEOUT_QUIET=true
GRUB_TIMEOUT=1
GRUB_DISTRIBUTOR="Proxmox Virtual Environment"
GRUB_DEFAULT=saved
GRUB_DISABLE_SUBMENU=true
GRUB_TERMINAL=serial
GRUB_SERIAL_COMMAND="serial --speed=115200 --unit=0 --word=8 --parity=no --stop=1"
GRUB_CMDLINE_LINUX_DEFAULT="console=tty0 console=ttyS0,115200n8"
GRUB_TERMINAL_OUTPUT="console"
GRUB_DISABLE_RECOVERY="true"
EOF

grub-mkconfig -o /boot/grub/grub.cfg

apt-get remove -y --auto-remove build-essential
apt-get autoremove -y
apt-get clean -y

# mark all free space
fstrim -av
