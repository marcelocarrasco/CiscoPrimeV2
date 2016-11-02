#!/bin/bash
<<COMMENT
Recibe la fecha a reprocesar
COMMENT

export ORACLE_HOME=/oracle/app/oracle/product/12.1.0.2/dbhome
export ORACLE_SID=DSMART2
export ORAENV_ASK=NO

sh /calidad/Pentaho61/data-integration/kitchen.sh -file=/calidad/CiscoPrime/PentahoSourceFiles/Rework/CiscoPrime_EndToEnd_Rework.kjb -param:FECHA_PROC=$1
exit
