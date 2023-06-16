#!/usr/bin/env bash
set -xe

#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

sudo wget https://enterprise.proxmox.com/debian/proxmox-release-bullseye.gpg -O \
  /etc/apt/trusted.gpg.d/proxmox-release-bullseye.gpg

sudo tee -a /etc/apt/sources.list.d/pmg-community.list > /dev/null << EOF
deb http://download.proxmox.com/debian/pmg bullseye pmg-no-subscription
EOF
sudo test -f /etc/apt/sources.list.d/pmg-enterprise.list \
  && sudo sed -i 's/^deb/#deb/g' /etc/apt/sources.list.d/pmg-enterprise.list

sudo apt update -y && sudo apt dist-upgrade -y

if [ "x$BUILD_TARGET" == "xcloud" ];then
sudo apt install -y proxmox-mailgateway
fi

if [ "x$BUILD_TARGET" == "xvagrant" ];then
sudo tee /etc/default/grub > /dev/null <<EOF
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
sudo grub-mkconfig -o /boot/grub/grub.cfg
fi

sudo apt-get remove -y --auto-remove build-essential
sudo apt-get autoremove -y
sudo apt-get clean -y

# mark all free space
sudo fstrim -av
