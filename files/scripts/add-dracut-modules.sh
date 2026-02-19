#!/usr/bin/env bash

echo 'run add-dracut-modules.sh'
mkdir -p /etc/dracut.conf.d
echo 'add_dracutmodules+=" fido2 "' > /etc/dracut.conf.d/fido2.conf
