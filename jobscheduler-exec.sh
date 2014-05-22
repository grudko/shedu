#!/bin/bash
# Run this script via SOS GmbH JobScheduler with job parameter "host" 
# and directory in edubba to pack and execute
[ -z $1 ] && { echo "Usage: $0 drectory_in_edubba"; exit 1; }
[ -d edubba/$1 ] || { echo "edubba/$1: no such directory"; exit 1; }
./shedurun.sh edubba/$1
[ -n "$SCHEDULER_PARAM_HOST" ] || { echo "Run this script via SOS GmbH JobScheduler with job parameter 'host'"; exit 1; }
HOST=$SCHEDULER_PARAM_HOST
ssh root@$HOST bash < edubba/$1/pack
