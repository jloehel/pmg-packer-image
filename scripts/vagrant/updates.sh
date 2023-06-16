#!/bin/bash -eux

cat > /etc/apt/apt.conf.d/51disable-unattended-upgrades << EOF
APT::Periodic::Update-Package-Lists "0";
APT::Periodic::Unattended-Upgrade "0";
EOF
