
--**********************************************************************************--
-- SECUENCIA PARA GENERAR EL ELEMENT_ID DE LA TABLA EHEALTH_OBJECTS
--**********************************************************************************--

CREATE SEQUENCE EHEALTH_ELEMENT_ID_SEQ INCREMENT BY 1 START WITH 4000000 MAXVALUE 9999999999999999999999999 NOCACHE;

--**********************************************************************************--
-- UPDATE ELEMENT_ALIASES BASADO EN LOS DATOS DE CISCO PRIME
--**********************************************************************************--

SELECT  'UPDATE EHEALTH_OBJECTS_AUX SET ELEMENT_ALIASES_NEW = '''||CSCO.ELEMENT_ALIASES||
        ''' WHERE ELEMENT_ID = '||HIST.ELEMENT_ID||';'
FROM  CSCO_DEVICE_LINKS CSCO,
      (SELECT ELEMENT_ID,
              ELEMENT_NAME,
              INTERFACE_NAME_NEW
      FROM  EHEALTH_OBJECTS_AUX
      WHERE FLAG_ENABLED = 'S'
      AND GRUPO != 'IPRAN') HIST
WHERE HIST.ELEMENT_NAME = AENDPOINT
AND   HIST.INTERFACE_NAME_NEW = PORTNUMBERA
ORDER BY HIST.ELEMENT_ID;
--
select  eoh.element_id,
        eoh.element_aliases,
        eoh.element_name,
        eoh.interface_name_new,
        --eoh.element_name||'-'||eoh.interface_name_new element_aliases_new,
        cdl.aendpoint||'-'||cdl.portnumbera||'_to_'||cdl.ZENDPOINT||'-'||cdl.PORTNUMBERZ element_aliases_new,
        cdl.aendpoint,
        cdl.portnumbera,
        cdl.ZENDPOINT,
        cdl.PORTNUMBERZ
        
from  EHEALTH_OBJECTS_AUX eoh,
      CSCO_DEVICE_LINKS cdl
where EOH.FLAG_ENABLED = 'S'
and EOH.GRUPO != 'IPRAN'
and EOH.INTERFACE_NAME_NEW is not null
and EOH.ELEMENT_NAME = CDL.AENDPOINT
and EOH.INTERFACE_NAME_NEW = CDL.PORTNUMBERA;
--**--**--**--**--**--**--**--**--**--**--**--**--**--
-- INSERTA LOS LINKS EN LA TABLA EHEALTH_OBJECTS
--**--**--**--**--**--**--**--**--**--**--**--**--**--
select  null                                                              ELEMENT_ID,
        AENDPOINT||'-'||PORTNUMBERA||'_to_'||ZENDPOINT||'-'||PORTNUMBERZ  ELEMENT_ALIASES,
        TRUNC(SYSDATE)                                                    VALID_START_DATE,
        TRUNC(SYSDATE)                                                    VALID_FINISH_DATE,
        NULL                                                              TIPO,
        AENDPOINT                                                         ORIGEN,
        ZENDPOINT                                                         DESTINO,
        'S'                                                               FLAG_ENABLED,
        NULL                                                              GRUPO,
        NULL                                                              PAIS,
        'RouterCisco'                                                     ELEMENT_TYPE,
        AENDPOINT                                                         ELEMENT_NAME,
        PORTNUMBERA                                                       INTERFACE_NAME,
        NULL                                                              GROUP_TYPE,
        NULL                                                              ELEMENT_IP,
        NULL                                                              NOMBRE_GRUPO,	
        NULL                                                              FRONTERA	
        --PORTNUMBERZ,
from  (select eoh.element_id,
              eoh.element_aliases element_aliases_ori,
              eoh.element_name,
              eoh.interface_name_new,
              --eoh.element_name||'-'||eoh.interface_name_new element_aliases_new,
              --cdl.aendpoint||'-'||cdl.portnumbera||'_to_'||cdl.ZENDPOINT||'-'||cdl.PORTNUMBERZ element_aliases_new,
              cdl.element_aliases element_aliases_new,
              cdl.aendpoint,
              cdl.portnumbera,
              cdl.ZENDPOINT,
              cdl.PORTNUMBERZ
              
      from  EHEALTH_OBJECTS_AUX eoh,
            CSCO_DEVICE_LINKS cdl
      where EOH.FLAG_ENABLED = 'S'
      and EOH.GRUPO != 'IPRAN'
      and EOH.INTERFACE_NAME_NEW is not null
      and EOH.ELEMENT_NAME = CDL.AENDPOINT
      and EOH.INTERFACE_NAME_NEW = CDL.PORTNUMBERA) 


/*(select AENDPOINT,
              PORTNUMBERA,
              ZENDPOINT,
              PORTNUMBERZ,
              LINKTYPE,
              ROWNUMBER,
              row_number() over (partition by AENDPOINT,PORTNUMBERA,ZENDPOINT,PORTNUMBERZ
                                order by AENDPOINT,PORTNUMBERA,ZENDPOINT,PORTNUMBERZ) rn
        from csco_device_links)*/
--where rn = 1;

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

