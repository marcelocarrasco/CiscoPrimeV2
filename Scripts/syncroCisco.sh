#!/bin/bash

<<COMMENT
Script para sincronizar los archivos de CISCO PRIME al server locar
PARAMS:	RUTA --> Directorio raiz del proyecto e.j. '/calidad/CiscoPrimre'
COMMENT
#
# echo $(date)
RUTA=$1

LISTA_OUTPUT=$1/Scripts/listaArc$(date +'%Y%m%d_%H').lst

FECHA_PROC=$(date +'%Y-%m-%d') #FECHA HORA (YYYY-MM-DD) que se quiere procesar (ej. 2016-12-01)

> $LISTA_OUTPUT
#
sed -e "s,$,$FECHA_PROC*,g" $RUTA/Scripts/includes.conf > $RUTA/Scripts/includes_usar.conf

echo "Copiando archivos origen --> destino"

rsync -zvrt --update --include-from=$RUTA/Scripts/includes_usar.conf --exclude="*" calidad@olivera.claro.amx:/opt/CSCOppm-gw/reports/exporthourly/ $RUTA/exporthourly/  > $LISTA_OUTPUT
 
# Agrego la ruta completa a los archivos
#sed -i "s,^,$RUTA/xml_output/,g" $LISTA_OUTPUT

# Revesa del archivo
#tac $LISTA_OUTPUT > $LISTA_OUTPUT.tmp

exit
