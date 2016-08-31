
--**********************************************************************************--
-- SECUENCIA PARA GENERAR EL ELEMENT_ID DE LA TABLA EHEALTH_OBJECTS
--**********************************************************************************--
DROP SEQUENCE EHEALTH_ELEMENT_ID_SEQ;
CREATE SEQUENCE EHEALTH_ELEMENT_ID_SEQ INCREMENT BY 1 START WITH 4000000 MAXVALUE 9999999999999999999999999 NOCACHE;

--**********************************************************************************--
-- UPDATE ELEMENT_ALIASES BASADO EN LOS DATOS DE CISCO PRIME
--**********************************************************************************--

SELECT  'UPDATE EHEALTH_OBJECTS_AUX SET ELEMENT_ALIASES_NEW = '''||CSCO.ELEMENT_ALIASES||
        ''' WHERE ELEMENT_ID = '||HIST.ELEMENT_ID||';'
FROM  (SELECT AENDPOINT,
              PORTNUMBERA,
              ZENDPOINT,
              PORTNUMBERZ,
              LINKTYPE,
              ROWNUMBER,
              ELEMENT_ALIASES,
              ROW_NUMBER() OVER (PARTITION BY AENDPOINT,PORTNUMBERA,ZENDPOINT,PORTNUMBERZ
                                ORDER BY AENDPOINT,PORTNUMBERA,ZENDPOINT,PORTNUMBERZ) rn
      FROM  CSCO_DEVICE_LINKS) CSCO,
-- 
      (SELECT ELEMENT_ID,
              ELEMENT_NAME,
              INTERFACE_NAME_NEW
      FROM  EHEALTH_OBJECTS_AUX
      WHERE FLAG_ENABLED = 'S'
      AND GRUPO != 'IPRAN') HIST
WHERE HIST.ELEMENT_NAME = AENDPOINT
AND   HIST.INTERFACE_NAME_NEW = PORTNUMBERA
AND   CSCO.rn = 1
ORDER BY HIST.ELEMENT_ID;

--**--**--**--**--**--**--**--**--**--**--**--**--**--
-- INSERTA LOS LINKS EN LA TABLA EHEALTH_OBJECTS
--**--**--**--**--**--**--**--**--**--**--**--**--**--
SELECT  (SELECT EHEALTH_ELEMENT_ID_SEQ.NEXTVAL() FROM DUAL) ELEMENT_ID,
        DATOS.ELEMENT_ALIASES             ELEMENT_ALIASES,
        TRUNC(SYSDATE)                    VALID_START_DATE,
        TRUNC(SYSDATE)                    VALID_FINISH_DATE,
        NULL                              TIPO,
        DATOS.AENDPOINT                   ORIGEN,
        DATOS.ZENDPOINT                   DESTINO,
        'S'                               FLAG_ENABLED,
        NULL                              GRUPO,
        NULL                              PAIS,
        'RouterCisco'                     ELEMENT_TYPE,
        DATOS.AENDPOINT                   ELEMENT_NAME,
        DATOS.PORTNUMBERA                 INTERFACE_NAME,
        NULL                              GROUP_TYPE,
        NULL                              ELEMENT_IP,
        NULL                              NOMBRE_GRUPO,	
        NULL                              FRONTERA,
        NULL                              SPEED_MODIFY
FROM  ( 
      SELECT  AENDPOINT,
              PORTNUMBERA,
              ZENDPOINT,
              PORTNUMBERZ,
              LINKTYPE,
              ROWNUMBER,
              ELEMENT_ALIASES,
              ROW_NUMBER() OVER (PARTITION BY AENDPOINT,PORTNUMBERA,ZENDPOINT,PORTNUMBERZ
                                 ORDER BY AENDPOINT,PORTNUMBERA,ZENDPOINT,PORTNUMBERZ) rn
      FROM  
            (-- ELEMENT_ALIASES que estan en CSCO_DEVICE_LINKS y no en EHEALTH_OBJECTS
            SELECT  ELEMENT_ALIASES ELEMENT_ALIASES_NEW
            FROM    CSCO_DEVICE_LINKS CSCO    
            MINUS
            SELECT  ELEMENT_ALIASES_NEW
            FROM    EHEALTH_OBJECTS_AUX EOH
            WHERE   EOH.FLAG_ENABLED  = 'S'
            AND     EOH.GRUPO         != 'IPRAN'
            AND     EOH.ELEMENT_ALIASES_NEW IS NOT NULL) LINKS,
            CSCO_DEVICE_LINKS CDL
      WHERE LINKS.ELEMENT_ALIASES_NEW = CDL.ELEMENT_ALIASES) DATOS
WHERE DATOS.rn = 1;
--***********************************************************************--
-- ELEMENT_ALIASES QUE ESTAN EN EHEALTH_OJECTS (HABILITADOS)
--***********************************************************************--

-- ELEMENT_ALIASES que estan en CSCO_DEVICE_LINKS y no en EHEALTH_OBJECTS
SELECT  ELEMENT_ALIASES ELEMENT_ALIASES_NEW
FROM  (
      SELECT  AENDPOINT,
              PORTNUMBERA,
              ZENDPOINT,
              PORTNUMBERZ,
              LINKTYPE,
              ROWNUMBER,
              ELEMENT_ALIASES--,
--              ROW_NUMBER() OVER (PARTITION BY AENDPOINT,PORTNUMBERA,ZENDPOINT,PORTNUMBERZ
--                                ORDER BY AENDPOINT,PORTNUMBERA,ZENDPOINT,PORTNUMBERZ) rn
      FROM  CSCO_DEVICE_LINKS) CSCO
--WHERE CSCO.rn = 1
MINUS
SELECT  ELEMENT_ALIASES_NEW
FROM  EHEALTH_OBJECTS_AUX EOH
WHERE EOH.FLAG_ENABLED = 'S'
AND EOH.GRUPO != 'IPRAN'
AND EOH.ELEMENT_ALIASES_NEW IS NOT NULL;
--******************************************--
-- POPULAR EHEALTH_STAT_IP_HOUR
--******************************************--
WITH  DATOS_EHEALTH_OBJECTS AS (SELECT  /*+ MATERIALIZE */
                                        EOH.ELEMENT_ID,
                                        EOH.ELEMENT_NAME,
                                        EOH.INTERFACE_NAME
                                FROM    EHEALTH_OBJECTS_AUX EOH
                                WHERE   EOH.FLAG_ENABLED = 'S'
                                AND     EOH.GRUPO != 'IPRAN'),
      DATOS_INTERFACES  AS  (SELECT /*+ MATERIALIZE */
                                    CIH.FECHA                         FECHA,
                                    DEO.ELEMENT_ID                    ELEMENT_ID,
                                    ROUND(CIH.RECEIVEBYTES*8/3600,2)  RECEIVEBYTES,
                                    ROUND(CIH.SENDBYTES*8/3600,2)     SENDBYTES,
                                    ROUND(CIH.IFSPEED/1000/1000,2)    IFSPEED,
                                    ROUND(CIH.RECEIVEDISCARDS/3600,2) RECEIVEDISCARDS,
                                    ROUND(CIH.SENDDISCARDS/3600,2)    SENDDISCARDS,
                                    CIH.RECEIVEERRORS                 RECEIVEERRORS,
                                    CIH.SENDERRORS                    SENDERRORS,
                                    CIH.RECEIVETOTALPKTRATE           RECEIVETOTALPKTRATE,
                                    CIH.SENDTOTALPKTRATE              SENDTOTALPKTRATE,
                                    CIE.INQUEUEDROPS                  INQUEUEDROPS,
                                    CIE.OUTQUEUEDROPS                 OUTQUEUEDROPS,
                                    CIA.UPPERCENT                     UPPERCENT,
                                    CIH.SENDUTIL                      SENDUTIL,
                                    CIH.SENDTOTALPKTS                 SENDTOTALPKTS,
                                    CIH.SENDUCASTPKTPERCENT           SENDUCASTPKTPERCENT,
                                    CIH.SENDMCASTPKTPERCENT           SENDMCASTPKTPERCENT,
                                    CIH.SENDBCASTPKTPERCENT           SENDBCASTPKTPERCENT,
                                    CIH.SENDERRORPERCENT              SENDERRORPERCENT,
                                    CIH.SENDDISCARDPERCENT            SENDDISCARDPERCENT,
                                    CIH.RECEIVEUTIL                   RECEIVEUTIL,
                                    CIH.RECEIVETOTALPKTS              RECEIVETOTALPKTS,
                                    CIH.RECEIVEUCASTPKTPERCENT        RECEIVEUCASTPKTPERCENT,
                                    CIH.RECEIVEMCASTPKTPERCENT        RECEIVEMCASTPKTPERCENT,
                                    CIH.RECEIVEBCASTPKTPERCENT        RECEIVEBCASTPKTPERCENT,
                                    CIH.RECEIVEERRORPERCENT           RECEIVEERRORPERCENT,
                                    CIH.RECEIVEDISCARDPERCENT         RECEIVEDISCARDPERCENT,
                                    CIH.SENDBCASTPKTRATE              SENDBCASTPKTRATE,
                                    CIH.RECEIVEBCASTPKTRATE           RECEIVEBCASTPKTRATE
                            FROM  DATOS_EHEALTH_OBJECTS DEO 
                            JOIN  CSCO_INTERFACE_HOUR CIH ON (DEO.ELEMENT_NAME  = CIH.NODE 
                                                             AND DEO.INTERFACE_NAME_NEW  = CIH.INTERFAZ)
                            JOIN  CSCO_INTERFACE_AVAIL_HOUR CIA ON (CIH.FECHA = CIA.FECHA 
                                                                    AND CIH.NODE = CIA.NODE 
                                                                    AND CIH.INTERFAZ = CIA.INTERFACE_DISP)
                            JOIN  CSCO_INTERFACE_ERRORS_HOUR  CIE ON  (CIA.FECHA  = CIE.FECHA
                                                                      AND CIA.NODE  = CIE.NODE
                                                                      AND CIA.INTERFACE_DISP  = CIE.IFEXTIFDESCR)
                            WHERE TRUNC(CIH.FECHA) = '23.08.2016'
                            --AND CIH.NODE = 'ngry01sw14'
                            )
SELECT  FECHA,
        ELEMENT_ID,
        RECEIVEBYTES,
        SENDBYTES,
        IFSPEED,
        RECEIVEDISCARDS,
        SENDDISCARDS,
        RECEIVEERRORS,
        SENDERRORS,
        RECEIVETOTALPKTRATE,
        SENDTOTALPKTRATE,
        INQUEUEDROPS,
        OUTQUEUEDROPS,
        UPPERCENT,
        SENDUTIL,
        SENDTOTALPKTS,
        SENDUCASTPKTPERCENT,
        SENDMCASTPKTPERCENT,
        SENDBCASTPKTPERCENT,
        SENDERRORPERCENT,
        SENDDISCARDPERCENT,
        RECEIVEUTIL,
        RECEIVETOTALPKTS,
        RECEIVEUCASTPKTPERCENT,
        RECEIVEMCASTPKTPERCENT,
        RECEIVEBCASTPKTPERCENT,
        RECEIVEERRORPERCENT,
        RECEIVEDISCARDPERCENT,
        SENDBCASTPKTRATE,
        RECEIVEBCASTPKTRATE
FROM    DATOS_INTERFACES;


SELECT  ELEMENT_ID,
        ELEMENT_NAME,
        INTERFACE_NAME_NEW
FROM  EHEALTH_OBJECTS_AUX EOH
WHERE EOH.FLAG_ENABLED = 'S'
AND   EOH.GRUPO != 'IPRAN'
AND   EOH.ELEMENT_ALIASES_NEW IS NOT NULL;

--***********************************--
-- Modificacion Historico
--***********************************--
--
-- Eth-4-1 y Eth-4-0
--
select  'update ehealth_objects_aux set interface_name_new = '''||
        replace(
        regexp_replace(interface_name,'Eth-','Ethernet'),'-','/')
        ||
        ''' where element_id = '||element_id||';'
from ehealth_objects
where GRUPO != 'IPRAN'
and REGEXP_LIKE(interface_name,'^Eth[-]');
--
-- Ethernet1-1
--
select  'update ehealth_objects_aux set interface_name_new = '''||
        replace(
        regexp_replace(interface_name,'Ethernet','Ethernet'),'-','/')
        ||
        ''' where element_id = '||element_id||';'
from ehealth_objects
where GRUPO != 'IPRAN'
and REGEXP_LIKE(interface_name,'^Ethernet[0-9]');
--
-- Ether2-4 y Ether2-5
--
select  'update ehealth_objects_aux set interface_name_new = '''||
        replace(
        regexp_replace(interface_name,'Ether','Ethernet'),'-','/')
        ||
        ''' where element_id = '||element_id||';'
from ehealth_objects
where GRUPO != 'IPRAN'
and REGEXP_LIKE(interface_name,'^Ether[0-9]');
--
--Fast2-1, Fast8-0-7, Fast0-6
--
select  'update ehealth_objects_aux set interface_name_new = '''||
        replace(
        regexp_replace(interface_name,'Fast','FastEthernet'),'-','/')
        ||
        ''' where element_id = '||element_id||';'
from ehealth_objects
where GRUPO != 'IPRAN'
and REGEXP_LIKE(interface_name,'^Fast[0-9]');
--
-- FastEthernet2-0
select  'update ehealth_objects_aux set interface_name_new = '''||
        replace(
        regexp_replace(interface_name,'FastEthernet','FastEthernet'),'-','/')
        ||
        ''' where element_id = '||element_id||';'
from ehealth_objects
where GRUPO != 'IPRAN'
and REGEXP_LIKE(interface_name,'^FastEthernet[0-9]');
--
-- Fa8-0-1, Fa8-0-1, Fa9-0-2
--
select  'update ehealth_objects_aux set interface_name_new = '''||
        replace(
        regexp_replace(interface_name,'Fa','FastEthernet'),'-','/')
        ||
        ''' where element_id = '||element_id||';'
from ehealth_objects
where GRUPO != 'IPRAN'
and REGEXP_LIKE(interface_name,'^Fa[0-9]');
--
-- Giga1-40, Giga1-34, Giga_8-0-11, Gigat0-0-0-1, GigabitEthernet1-40
--
select  'update ehealth_objects_aux set interface_name_new = '''||
        replace(
        regexp_replace(interface_name,'Giga','GigabitEthernet'),'-','/')
        ||
        ''' where element_id = '||element_id||';'
from ehealth_objects
where GRUPO != 'IPRAN'
and REGEXP_LIKE(interface_name,'^Giga[0-9]');
--
-- GigabitEthernet
select  'update ehealth_objects_aux set interface_name_new = '''||
        replace(
        regexp_replace(interface_name,'GigabitEthernet','GigabitEthernet'),'-','/')
        ||
        ''' where element_id = '||element_id||';'
from ehealth_objects
where GRUPO != 'IPRAN'
and REGEXP_LIKE(interface_name,'^GigabitEthernet[0-9]');
--
-- Giga_8-0-18, Giga_8-0-8
--
select  'update ehealth_objects_aux set interface_name_new = '''||
        replace(
        regexp_replace(interface_name,'Giga_','GigabitEthernet'),'-','/')
        ||
        ''' where element_id = '||element_id||';'
from ehealth_objects
where GRUPO != 'IPRAN'
and REGEXP_LIKE(interface_name,'^Giga[_]');
--
--Hun0-1-0-0, Hun0-2-0-0, Hun0-1-0-0, Hun0-2-0-0
--
select  'update ehealth_objects_aux set interface_name_new = '''||
        replace(
        regexp_replace(interface_name,'Hun','HundredGigE'),'-','/')
        ||
        ''' where element_id = '||element_id||';'
from ehealth_objects
where GRUPO != 'IPRAN'
and REGEXP_LIKE(interface_name,'^Hun[0-9]'); 
--
--Serial5-2-0, Serial4-0-0, Serial9-1-6, Serial2-7-0
--
select  'update ehealth_objects_aux set interface_name_new = '''||
        replace(
        regexp_replace(interface_name,'Serial','Serial'),'-','/')
        ||
        ''' where element_id = '||element_id||';'
from ehealth_objects
where GRUPO != 'IPRAN'
and REGEXP_LIKE(interface_name,'^Serial[0-9]');
--
-- Serial-2-5-0,Serial-2-2-1, Serial-1-0
--
select  'update ehealth_objects_aux set interface_name_new = '''||
        replace(
        regexp_replace(interface_name,'Serial-','Serial'),'-','/')
        ||
        ''' where element_id = '||element_id||';'
from ehealth_objects
where GRUPO != 'IPRAN'
and REGEXP_LIKE(interface_name,'^Serial-[0-9]');
--
--PortChannel-20,PortChannel-20,PortChannel-111,PortChannel-1,PortChannel-111B --> DONE
--PortChannel11,PortChannel22 --> DONE
--Pos0-6-0-0,Pos0-7-0-0 --> DONE
--Po9,Po10 --> DONE
--Port-channel1,Port-Channel-11 --> DONE
select  'update ehealth_objects_aux set interface_name_new = '''||
        regexp_replace(replace(interface_name,'-',''),'PortChannel','Port-channel')
        ||
        ''' where element_id = '||element_id||';'
from ehealth_objects
where GRUPO != 'IPRAN'
and REGEXP_LIKE(interface_name,'^Port-Channel-[0-9]');
--
--Bundle-Ether1, Bundle-Ether4, Bundle-Ethernet7
--
select  'update ehealth_objects_aux set interface_name_new = '''||
        regexp_replace(replace(interface_name,'-','/'),'Bundle/Ether','Bundle-Ether')||
        ''' where element_id = '||element_id||';'
from ehealth_objects
where GRUPO != 'IPRAN'
and REGEXP_LIKE(interface_name,'^Bundle-Ether');
--
-- Bundle1, Bundle4-172, Bundle1-2000
--
select  'update ehealth_objects_aux set interface_name_new = '''||
        regexp_replace(replace(interface_name,'-','/'),'Bundle','Bundle-Ether')
        ||
        ''' where element_id = '||element_id||';'
from ehealth_objects
where GRUPO != 'IPRAN'
and REGEXP_LIKE(interface_name,'^Bundle[0-9]');
--
--Bundle-9, Bundle-10, Bundle-7
--
select  'update ehealth_objects_aux set interface_name_new = '''||
        regexp_replace(interface_name,'Bundle-','Bundle-Ether')
        ||
        ''' where element_id = '||element_id||';'
from ehealth_objects
where GRUPO != 'IPRAN'
and REGEXP_LIKE(interface_name,'^Bundle-[0-9]');
--
select  'update ehealth_objects_aux set interface_name_new = '''||
        regexp_replace(interface_name,'Bundle-Ethernet','Bundle-Ether')
        ||
        ''' where element_id = '||element_id||';'
from ehealth_objects
where GRUPO != 'IPRAN'
and REGEXP_LIKE(interface_name,'^Bundle-Ethernet[0-9]');
--
-- Multilink2, Multilink12, Multilink11
--
select  'update ehealth_objects_aux set interface_name_new = '''||
        regexp_replace(interface_name,'Multilink','Multilink')
        ||
        ''' where element_id = '||element_id||';'
from ehealth_objects
where GRUPO != 'IPRAN'
and REGEXP_LIKE(interface_name,'^Multilink[0-9]');
--
-- Vlan324, Vlan324, Vlan630, Vlan630, Vlan620, Vlan620
--
select  'update ehealth_objects_aux set interface_name_new = '''||
        regexp_replace(interface_name,'Vlan','Vlan')
        ||
        ''' where element_id = '||element_id||';'
from ehealth_objects
where GRUPO != 'IPRAN'
and REGEXP_LIKE(interface_name,'^Vlan[0-9]');
--
--TenGiga3-0-1,TenGiga0-0-4-0 --> DONE
--
select  'update ehealth_objects_aux set interface_name_new = '''||
        replace(
        regexp_replace(interface_name,'Ten','TenGigabitEthernet'),'-','/')
        ||
        ''' where element_id = '||element_id||';'
from ehealth_objects
where GRUPO != 'IPRAN'
and REGEXP_LIKE(interface_name,'^Ten[0-9]');
--
--Ten7-0-1,Ten7-1,Ten7-0-1 --> DONE --> DONE
select  'update ehealth_objects_aux set interface_name_new = '''||
        replace(
        regexp_replace(interface_name,'TenGiga','TenGigabitEthernet'),'-','/')
        ||
        ''' where element_id = '||element_id||';'
from ehealth_objects
where GRUPO != 'IPRAN'
and REGEXP_LIKE(interface_name,'^TenGiga[0-9]');
--
--TenGiga_1-1,TenGiga_1-2,TenGiga_1-3
select  'update ehealth_objects_aux set interface_name_new = '''||
        replace(
        regexp_replace(interface_name,'TenGiga_','TenGigabitEthernet'),'-','/')
        ||
        ''' where element_id = '||element_id||';'
from ehealth_objects
where GRUPO != 'IPRAN'
and REGEXP_LIKE(interface_name,'^TenGiga_[0-9]');

--
--TenGigabitEthernet9-0-1,TenGigabitEthernet2-4,TenGigabitEthernet2-4
select  'update ehealth_objects_aux set interface_name_new = '''||
        replace(
        regexp_replace(interface_name,'TenGigabitEthernet','TenGigabitEthernet'),'-','/')
        ||
        ''' where element_id = '||element_id||';'
from ehealth_objects
where GRUPO != 'IPRAN'
and REGEXP_LIKE(interface_name,'^TenGigabitEthernet[0-9]');
--
-- Reemplazo el caracter '.' por el caracter '/' segun lo indicado
--
update ehealth_objects_aux set
INTERFACE_NAME_NEW = replace(INTERFACE_NAME_NEW,'.','/');

update ehealth_objects_aux set
  INTERFACE_NAME_NEW = replace(INTERFACE_NAME_NEW,'_','/')
where ELEMENT_ID = 2639233;

-- Reemplazo de los datos de TenGigE en las tablas de INTERFACE
--
--TenGigE
set pagesize 50000
set lines 200
set feedback off
set title off
set echo off
spool /home/oracle/CiscoPrimeV2/Scripts/upTenGigE.sql
select  'update csco_interface_hour set interfaz = '''||
        replace(
        regexp_replace(interfaz,'TenGigE','TenGigabitEthernet'),'.','/')
        ||
        ''' where node = '''||node||''' and interfaz = '''||interfaz||''';'       
from csco_interface_hour
where REGEXP_LIKE(interfaz,'^TenGigE[0-9]');
spool off