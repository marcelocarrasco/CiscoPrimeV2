#!/bin/bash
<<COMMENT
Se utiliza para llenar la tabla INVENTORY que contiene datos de los equipos CISCO
Este script es llamado desde Pentaho, recibe como parametros:
DB-USER, DB-NOENC-PASS, DB-NAME
COMMENT
#export ORACLE_HOME=/oracle/app/oracle/product/12.1.0.2/dbhome
#export ORACLE_SID=DSMART2
#export ORAENV_ASK=NO

sqlplus  $1/$2@$3 << EOF 
declare
  cursor indx is
  select  rownumber,
          substr(linea,6,length(linea)) clave,
          substr(valor,8,length(valor)) valor
  from CSCO_INVENTORY_AUX
  order by rownumber;
  type ini_fin is record(
    rownumber  number,
    clave        varchar2(30 char),
    valor       varchar2(4000 char)
    );
  --
  type contenedor is table of varchar2(2000 char) index by varchar2(30 char);
  type ini_fin_tab is table of ini_fin index by pls_integer;
  
  vIniFinTab ini_fin_tab;
  vContenedor contenedor;
  
  vIndice     varchar2(30 char) := '-';
  vIndiceFin  varchar2(30 char) := 'InvestigationStateEnum';
  
begin
  execute immediate 'TRUNCATE TABLE CSCO_INVENTORY';
  open indx;
  loop
  begin
    fetch indx bulk collect into vIniFinTab limit 1;--get 'CommunicationStateEnum';
    exit when indx%notfound;
    vContenedor('rownumber') := vIniFinTab(1).rownumber;
    vContenedor(vIniFinTab(1).clave) := vIniFinTab(1).valor;-- value of 'CommunicationStateEnum'
    vIndice := 'CommunicationStateEnum';
    while vIndice != vIndiceFin loop
      fetch indx bulk collect into vIniFinTab limit 1;
      vContenedor(vIniFinTab(1).clave) := vIniFinTab(1).valor;
      vIndice := vIniFinTab(1).clave;
    end loop;
    insert into CSCO_INVENTORY (INVENTORY_ID,DEVICE,DEVICE_SERIES,ELEMENT_TYPE,IP_ADDRESS)
    values (standard_hash(vContenedor('DeviceName'), 'MD5'),vContenedor('DeviceName'),substr(vContenedor('DeviceSerialNumber'),1,instr(vContenedor('DeviceSerialNumber'),' ',1)),vContenedor('ElementType'),vContenedor('IP'));
    EXCEPTION
          WHEN OTHERS THEN
            G_ERROR_LOG_NEW.P_LOG_ERROR('P_INVENTORY_INS',
                                      SQLCODE,
                                      SQLERRM,
                                      'Error al insertar datos, puede que falte alguna de las columnas necesarias. Ver fila :'||to_char(vContenedor('rownumber')));
  end;
  end loop;
  close indx;
  commit;
end;
/
exit;
EOF
