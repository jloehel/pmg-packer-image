#!/usr/bin/env bash
set -xe

export DEBIAN_FRONTEND=noninteractive

apt install -y cloud-init cloud-initramfs-growroot

# Cleanup
rm -rf /var/lib/cloud/*
rm -f /var/log/cloud-init.log
rm -rf /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg
rm -rf /etc/cloud/cloud.cfg.d/99-installer.cfg


