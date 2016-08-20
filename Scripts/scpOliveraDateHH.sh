#!/bin/bash
<<'COMMENT'
Este script copia el archivo de una determinada fecha-hora.
La idea es utilizarlo en los casos de rework donde los archivos fallaron o no existian en el origen.
Usage: scoOliveraDateHH.sh 'NOMBRE.YYYY-MM-DD-HH' ej. scoOliveraDateHH.sh 'CGN_STATS.2016-08-14-00'
COMMENT
scp calidad@olivera.claro.amx:/opt/CSCOppm-gw/reports/exporthourly/$1* /calidad/CiscoPrime/exporthourly
exit
