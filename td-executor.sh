#!/bin/bash
[ -z $1 ] && { echo "Usage: $0 drectory_in_edubba"; exit 1; }
 [ -d edubba/$1 ] || { echo "edubba/$1: no such directory"; exit 1; }
cp td-observer.py edubba/$1/bundle/td-observer.py
./shedupack.sh -c "HOST=$HOST TASK=$1 TASKID=$TASKID ./td-observer.py run.sh" edubba/$1
[ -n "$HOST" ] && {
  scp ./$1.sh $HOST:~/
  ssh root@$HOST ~/$1.sh
} || ./$1.sh

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
exit $ECODE
