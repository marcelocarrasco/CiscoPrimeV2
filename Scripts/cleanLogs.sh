#!/bin/bash

RUTA=$1
LINES=1
a=0

for f in $RUTA/*.log
do
  a=$( cat $f | wc -l ) #| sed 's/^\([0-9]*\).*$/\1/'`
  if [ "$a" -eq "$LINES" ]
  then
    #rm -f "$f"
    echo "$f"
  fi
done
