#!/usr/bin/env bash

set -o errexit

apt-get autoremove
apt-get clean

rm -f /etc/ssh/ssh_host_*
tee /etc/rc.local >/dev/null <<EOL
#!/bin/sh -e
#
# rc.local
#
# This script is executed at the end of each multiuser runlevel.
# Make sure that the script will "" on success or any other
# value on error.
#
# In order to enable or disable this script just change the execution
# bits.
#

# By default this script does nothing.
test -f /etc/ssh/ssh_host_dsa_key || dpkg-reconfigure openssh-server
exit 0
EOL
chmod +x /etc/rc.local

rm -f /var/lib/systemd/random-seed
rm -rf /tmp/*
rm -rf /var/tmp/*


>/var/log/lastlog
>/var/log/wtmp
>/var/log/btmp
>/var/log/audit/audit.log

rm -f /etc/udev/rules.d/70-persistent-net.rules;
mkdir -p /etc/udev/rules.d/70-persistent-net.rules;
rm -f /lib/udev/rules.d/75-persistent-net-generator.rules;

unset HISTFILE
history -cw
echo > ~/.bash_history
rm -fr /root/.bash_history

sync
