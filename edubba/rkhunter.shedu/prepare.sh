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
EOF
cd $1/bin
./rkhunter --update --report-warnings-only
ECODE=$?
cd $OLDPWD
rm -f $1/var/lib/rkhunter/tmp/group
rm -f $1/var/lib/rkhunter/tmp/passwd
exit $ECODE
