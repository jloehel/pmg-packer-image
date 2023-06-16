#!/bin/bash -eux

export DEBIAN_FRONTEND="noninteractive"

date > /vagrant_box_build_time

VAGRANT_USER="vagrant"
VAGRANT_USER_HOME="/home/${VAGRANT_USER}"

useradd -p vagrant -m $VAGRANT_USER

# Set up sudo
echo "==> Giving ${VAGRANT_USER} sudo powers"
echo "${VAGRANT_USER}        ALL=(ALL)       NOPASSWD: ALL" > /etc/sudoers.d/vagrant

echo "==> Installing vagrant key"
if [ ! -d "${VAGRANT_USER_HOME}/.ssh" ]; then
  mkdir "${VAGRANT_USER_HOME}/.ssh"
fi
chmod 700 "${VAGRANT_USER_HOME}/.ssh"


wget --no-check-certificate \
    'https://raw.githubusercontent.com/hashicorp/vagrant/master/keys/vagrant.pub' \
    -O ${VAGRANT_USER_HOME}/.ssh/authorized_keys
chmod 600 "${VAGRANT_USER_HOME}/.ssh/authorized_keys"
chown -R "${VAGRANT_USER}:${VAGRANT_USER}" "${VAGRANT_USER_HOME}/.ssh"

apt-get install -qq -y --no-install-recommends libpam-systemd > /dev/null
