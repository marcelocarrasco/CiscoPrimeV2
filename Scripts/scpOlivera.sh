#!/bin/bash

scp calidad@olivera.claro.amx:/opt/CSCOppm-gw/reports/exporthourly/CPU.$(date --date=''yesterday'' +%Y-%m-%d)* /calidad/CiscoPrime/exporthourly
scp calidad@olivera.claro.amx:/opt/CSCOppm-gw/reports/exporthourly/MEMORY.$(date --date=''yesterday'' +%Y-%m-%d)*  /calidad/CiscoPrime/exporthourly
scp calidad@olivera.claro.amx:/opt/CSCOppm-gw/reports/exporthourly/INTERFACE.$(date --date=''yesterday'' +%Y-%m-%d)* /calidad/CiscoPrime/exporthourly
scp calidad@olivera.claro.amx:/opt/CSCOppm-gw/reports/exporthourly/INTERFACE_AVAIL.$(date --date=''yesterday'' +%Y-%m-%d)* /calidad/CiscoPrime/exporthourly
scp calidad@olivera.claro.amx:/opt/CSCOppm-gw/reports/exporthourly/INTERFACE_ERRORS.$(date --date=''yesterday'' +%Y-%m-%d)* /calidad/CiscoPrime/exporthourly
