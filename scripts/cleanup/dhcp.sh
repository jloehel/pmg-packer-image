#!/usr/bin/env bash

set -o errexit

lease_data_locations=(
    "/var/lib/dhclient/*"
    "/var/lib/dhcp/*"
    "/var/lib/NetworkManager/*"
)

shopt -s nullglob dotglob

for lease_file in ${lease_data_locations[@]}; do
    rm -f "${lease_file}"
done

exit 0
