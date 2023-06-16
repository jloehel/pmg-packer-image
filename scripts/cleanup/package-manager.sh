#!/usr/bin/env bash

set -o errexit

cache_locations=(
    "/var/cache/apt/"
    "/var/cache/debconf"
    "/var/lib/apt/lists/"
)

for cache_dir in ${cache_locations[@]}
do
    if [ -d "${cache_dir}" ]; then
        find "${cache_dir}" -type f -delete
    fi
done

exit 0
