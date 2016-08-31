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
        ''' where node = '''||node||''' and interfaz = '''||interfaz||''';' as linea      
from csco_interface_hour
where REGEXP_LIKE(interfaz,'^TenGigE[0-9]');
spool off
exit;
