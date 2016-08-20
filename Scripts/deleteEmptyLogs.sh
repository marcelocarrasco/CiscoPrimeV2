#!/bin/bash

RUTA=$1
LINES=1
a=0
#echo "$RUTA"
for f in $RUTA/*.log; do
  a=$( wc -l $f | sed 's/^\([0-9]*\).*$/\1/' )
  if [ "$a" -le "$LINES" ]
  then
    rm -f "$f"
    #echo "$f"
  fi
done
