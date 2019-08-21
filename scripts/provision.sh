#!/usr/bin/env bash
set -xe

echo "deb http://download.proxmox.com/debian stretch pve-no-subscription" >> /etc/apt/sources.list
echo "deb http://download.proxmox.com/debian stretch pvetest" >> /etc/apt/sources.list
sed -i 's/^deb/#deb/g' /etc/apt/sources.list.d/pve-enterprise.list

apt-get dist-upgrade -y
apt-get install -y qemu-guest-agent cloud-init openssh-server curl iotop vim \
                   git lm-sensors sg3-utils ethtool iperf ansible ntp ntpdate \
                   ntpstat rdate sysbench nmap arp-scan gdebi-core pssh \
                   traceroute debian-goodies tmux

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

systemctl enable cloud-init
systemctl enable cloud-config
systemctl enable cloud-final
systemctl enable cloud-init-local

apt-get remove -y --auto-remove build-essential
apt-get autoremove -y
apt-get clean -y

# mark all free space
fstrim -av
