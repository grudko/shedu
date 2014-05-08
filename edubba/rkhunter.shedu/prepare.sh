#!/bin/bash
DIST=rkhunter-1.4.2
TARBALL=${DIST}.tar.gz
mkdir -p bundle
wget -O bundle/$TARBALL http://downloads.sourceforge.net/project/rkhunter/rkhunter/1.4.2/$TARBALL
install -m 755 run.sh.template bundle/run.sh
sed -i "s/__TARBALL__/$TARBALL/" bundle/run.sh
