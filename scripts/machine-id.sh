#!/usr/bin/env bash

set -o errexit

sysd_id="/etc/machine-id"
dbus_id="/var/lib/dbus/machine-id"

if [[ -e ${sysd_id} ]]; then
    rm -f ${sysd_id} && touch ${sysd_id}
fi

if [[ -e ${dbus_id} && ! -h ${dbus_id} ]]; then
    rm -f ${dbus_id}
fi

exit 0
