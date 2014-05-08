#!/bin/bash
# Run this script via SOS GmbH JobScheduler with job parameter "host" 
# and directory in edubba to pack and execute
[ -z $1 ] && { echo "Usage: $0 drectory_in_edubba"; exit 1; }
[ -d edubba/$1 ] || { echo "edubba/$1: no such directory"; exit 1; }
[ -d edubba/$1/bundle ] || ( cd edubba/$1; ./prepare.sh; ) || { echo "edubba/$1/prepare.sh: Can't prepare bundle"; exit 1; }
./shedupack.sh -f edubba/$1/$1.pack edubba/$1/bundle
[ -n "$SCHEDULER_PARAM_HOST" ] || { echo "Run this script via SOS GmbH JobScheduler with job parameter 'host'"; exit 1; }
HOST=$SCHEDULER_PARAM_HOST
scp edubba/$1/$1.pack root@$HOST:/tmp/
ssh root@$HOST /tmp/$1.pack
