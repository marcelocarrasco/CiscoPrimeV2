#!/bin/bash

sed -e '/Data File/b' -e '/Total logical/b' -e '/Bad File/b' -e d  $1 | sed -e 's/.*= \(.*\) \(.*\)/"\2, \1",/' -e 's/.*= \(.*\)/"\1",/' -e 's/.*: \(.*\)/"\1",/' -e 's/"\(.*\) ..:..:.*/"\1"/' | tr -d '\n'  >> /home/calidad/CiscoPrime/exporthourly/$2
