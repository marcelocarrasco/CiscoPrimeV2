#!/bin/bash

PATH=$1
LINES=1
a=0
echo "$PATH"
for f in $PATH/*.log; do
  a=wc -l $f | sed 's/^\([0-9]*\).*$/\1/'
  #if [ "$a" -eq "$LINES" ]
  #then
    #rm -f "$f"
    echo "$a"
  #fi
done
