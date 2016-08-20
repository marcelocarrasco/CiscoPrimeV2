#!/bin/bash

# scp calidad@olivera.claro.amx:/opt/CSCOppm-gw/reports/exporthourly/CPU.$(date --date=''yesterday'' +%Y-%m-%d)* /calidad/CiscoPrime/exporthourly
# scp calidad@olivera.claro.amx:/opt/CSCOppm-gw/reports/exporthourly/MEMORY.$(date --date=''yesterday'' +%Y-%m-%d)* /calidad/CiscoPrime/exporthourly
scp calidad@olivera.claro.amx:/opt/CSCOppm-gw/reports/exporthourly/INTERFACE.$(date --date=''yesterday'' +%Y-%m-%d)* /calidad/CiscoPrime/exporthourly
scp calidad@olivera.claro.amx:/opt/CSCOppm-gw/reports/exporthourly/INTERFACE_AVAIL.$(date --date=''yesterday'' +%Y-%m-%d)* /calidad/CiscoPrime/exporthourly
scp calidad@olivera.claro.amx:/opt/CSCOppm-gw/reports/exporthourly/INTERFACE_ERRORS.$(date --date=''yesterday'' +%Y-%m-%d)* /calidad/CiscoPrime/exporthourly
scp calidad@olivera.claro.amx:/opt/CSCOppm-gw/reports/exporthourly/CGN_STATS.$(date --date=''yesterday'' +%Y-%m-%d)* /calidad/CiscoPrime/exporthourly
scp calidad@olivera.claro.amx:/opt/CSCOppm-gw/reports/exporthourly/CPU_DEVICE_AVG.$(date --date=''yesterday'' +%Y-%m-%d)* /calidad/CiscoPrime/exporthourly
scp calidad@olivera.claro.amx:/opt/CSCOppm-gw/reports/exporthourly/MEMORY_DEVICE_AVERAGE.$(date --date=''yesterday'' +%Y-%m-%d)* /calidad/CiscoPrime/exporthourly
# scp calidad@olivera.claro.amx:/opt/CSCOppm-gw/reports/exporthourly/CPU_LOADAVG.$(date --date=''yesterday'' +%Y-%m-%d)* /calidad/CiscoPrime/exporthourly
exit
