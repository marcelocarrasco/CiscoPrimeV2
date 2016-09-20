#!/bin/bash
<<COMMENT
Se utiliza para generar el archivo ANA_BQL_NEs_Netcracker_Preliminar_PHYSICAL_IP_COMMA.xml (clave,valor) 
conteniendo las filas que se encuentran entre: CommunicationStateEnum y InvestigationStateEnum
a partir del archivo ANA_BQL_NEs_Netcracker_Preliminar_PHYSICAL_IP.xml

Usage: makeKVP.sh 'ANA_BQL_NEs_Netcracker_Preliminar_PHYSICAL_IP.xml' 'ANA_BQL_NEs_Netcracker_Preliminar_PHYSICAL_IP_COMMA.csv'
COMMENT
##
> $2
sed -n '/CommunicationStateEnum/,/InvestigationStateEnum/{p}' $1 > $2
exit
