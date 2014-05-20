#!/bin/bash
OLDPWD=`pwd`
cd $(dirname `readlink -f $0`)
. vars.sh
mkdir -p src
cd src
[ -f $TARBALL ] && exit 0
wget http://downloads.sourceforge.net/project/rkhunter/rkhunter/1.4.2/$TARBALL
tar -xf $TARBALL
cd $OLDPWD
