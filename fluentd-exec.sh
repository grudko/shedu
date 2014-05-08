#!/bin/bash
[ -z $1 ] && { echo "Usage: $0 drectory_in_edubba"; exit 1; }
[ -d edubba/$1/bundle ] || { echo "edubba/$1/bundle: no such directory"; exit 1; }
TMPDIR=`mktemp -d /tmp/shedu.bundle.XXXXXX`
cp -a edubba/$1/bundle $TMPDIR/
cp fluentd-executor/fluentd-observer.py $TMPDIR/bundle/fluentd-observer.py
./shedupack.sh -c "HOST=$HOST TASK=$1 TASKID=$TASKID ./fluentd-observer.py run.sh" -f $TMPDIR/$1.pack $TMPDIR/bundle
[ -n "$HOST" ] && {
  scp $TMPDIR/$1.pack root@$HOST:/tmp/
  ssh root@$HOST /tmp/$1.pack
} || $TMPDIR/$1.pack

OUTPATH=/var/log/td-agent/shedu/$HOST/${1//./\/}/$TASKID/`date +%Y%m%d`/*
echo $OUTPATH

while true ; do
 if grep '^[^ ]* *{"exitcode":\([0-9]*\)}$' $OUTPATH 2>/dev/null; then
  break
 fi
 sleep .1
done
ECODE=`grep  '^[^ ]* *{"exitcode":\([0-9]*\)}$' $OUTPATH|cut -d":" -f6|tr -d '}'`
echo $ECODE
rm -rf $TMPDIR
exit $ECODE
