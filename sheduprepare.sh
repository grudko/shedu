#!/bin/bash
for dir in edubba/*;do 
  if [ -d $dir ] && [ -e $dir/prepare.sh ]; then
    echo "Preparing $dir"
    (cd $dir && ./prepare.sh)
  fi
done
