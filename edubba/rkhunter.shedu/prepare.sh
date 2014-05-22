#!/bin/bash
OLDPWD=`pwd`
cd $(dirname `readlink -f $0`)
. vars.sh
install -m 755 run.sh.template $1/run.sh
cd src/$DIST
./installer.sh --layout custom $1 --install
cat <<EOF >>$1/etc/rkhunter.conf
ALLOW_SSH_ROOT_USER=without-password
PKGMGR=DPKG
ALLOWHIDDENDIR=/etc/.java
ALLOWHIDDENDIR=/dev/.udev
ALLOWHIDDENFILE=/dev/.initramfs
ALLOWDEVFILE=/dev/kmsg
ALLOWDEVFILE="/dev/.udev/queue.bin"
ALLOWDEVFILE="/dev/.udev/db/net:eth0"
ALLOWDEVFILE="/dev/.udev/db/input:*"
ALLOWDEVFILE="/dev/.udev/db/block:*"
ALLOWDEVFILE="/dev/.udev/db/usb:*"
ALLOWDEVFILE="/dev/.udev/db/drm:card0"
ALLOWDEVFILE="/dev/.udev/rules.d/99-root.rules"
ALLOWDEVFILE="/dev/.udev/rules.d/root.rules"
XINETD_ALLOWED_SVC=/etc/xinetd.d/reload_php
XINETD_ALLOWED_SVC=/etc/xinetd.d/firebird25
DISABLE_TESTS=avail_modules loaded_modules suspscan hidden_ports hidden_procs deleted_files packet_cap_apps
EOF
cd $1/bin
./rkhunter --update --report-warnings-only
ECODE=$?
cd $OLDPWD
rm -f $1/var/lib/rkhunter/tmp/group
rm -f $1/var/lib/rkhunter/tmp/passwd
exit $ECODE
