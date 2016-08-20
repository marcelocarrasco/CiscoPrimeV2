#!/bin/bash
<<'COMMENT'
Este script copia todos los archivos mencionados de una determinada fecha.
La idea es utilizarlo en los casos de rework donde todos los archivos fallaron o no existian en el origen.
Usage: scoOliveraDate.sh 'YYYY-MM-DD'
COMMENT
# scp calidad@olivera.claro.amx:/opt/CSCOppm-gw/reports/exporthourly/CPU.$1* /calidad/CiscoPrime/exporthourly
# scp calidad@olivera.claro.amx:/opt/CSCOppm-gw/reports/exporthourly/MEMORY.$1* /calidad/CiscoPrime/exporthourly
scp calidad@olivera.claro.amx:/opt/CSCOppm-gw/reports/exporthourly/INTERFACE.$1* /calidad/CiscoPrime/exporthourly
scp calidad@olivera.claro.amx:/opt/CSCOppm-gw/reports/exporthourly/INTERFACE_AVAIL.$1* /calidad/CiscoPrime/exporthourly
scp calidad@olivera.claro.amx:/opt/CSCOppm-gw/reports/exporthourly/INTERFACE_ERRORS.$1* /calidad/CiscoPrime/exporthourly
scp calidad@olivera.claro.amx:/opt/CSCOppm-gw/reports/exporthourly/CGN_STATS.$1* /calidad/CiscoPrime/exporthourly
scp calidad@olivera.claro.amx:/opt/CSCOppm-gw/reports/exporthourly/CPU_DEVICE_AVG.$1* /calidad/CiscoPrime/exporthourly
scp calidad@olivera.claro.amx:/opt/CSCOppm-gw/reports/exporthourly/MEMORY_DEVICE_AVERAGE.$1* /calidad/CiscoPrime/exporthourly
# scp calidad@olivera.claro.amx:/opt/CSCOppm-gw/reports/exporthourly/CPU_LOADAVG.$1* /calidad/CiscoPrime/exporthourly
exit
