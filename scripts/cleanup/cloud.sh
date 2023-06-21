#!/usr/bin/env bash

set -o errexit

sudo apt-get autoremove
sudo apt-get clean

sudo sed -i s/^admin:[^:]*/admin:*/ /etc/shadow
sudo rm -fr /home/admin/.ssh
sudo rm -fr /home/admin/.cache
sudo rm -fr /etc/ssh/ssh_host_*

sudo rm -f /var/lib/systemd/random-seed
sudo rm -rf /tmp/*
sudo rm -rf /var/tmp/*

sudo rm -f /etc/network/interfaces.d/*

unset HISTFILE
history -cw
echo > ~/.bash_history
rm -fr /home/admin/.bash_history

sync
