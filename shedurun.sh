#!/bin/bash
PORTDIR=`readlink -f $1`
set -e
$PORTDIR/download.sh
bundleprepare_tmp=`mktemp -d /tmp/shedu.bundleprepare.XXXXXX`
installdir=`mktemp -d /tmp/shedu.XXXXXX`
writedir=$bundleprepare_tmp/writedir
chrootdir=$bundleprepare_tmp/chrootdir
mkdir -p $writedir
mkdir -p $chrootdir
sudo unionfs-fuse -o cow -o allow_other,use_ino,suid,dev,nonempty $writedir=RW:/=RO $chrootdir
sudo chroot $chrootdir $PORTDIR/prepare.sh $installdir
sudo fusermount -u $chrootdir
rmdir $installdir
sudo chown `whoami`: -R $bundleprepare_tmp

./shedupack.sh -d $installdir -f $PORTDIR/pack $writedir/$installdir
rm -rf $bundleprepare_tmp
