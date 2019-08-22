#!/usr/bin/env bash
set -xe

# enable DHCP on all network interfaces by default
cat >/etc/network/interfaces <<EOF
auto lo
iface lo inet loopback

auto ens3
allow-hotplug ens3
iface ens3 inet dhcp
EOF
