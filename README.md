shedu
===


Utility for creating and remote start self-contained self-extracting packages

Installation
------------

Install unionfs-fuse and add this to your sudoers:

    USERNAME   ALL=(ALL) NOPASSWD: /usr/bin/unionfs-fuse *, /usr/sbin/chroot *, /bin/fusermount *,/bin/chown USERNAME\: -R *

