set pagesize 50000
set lines 200
set feedback off
set title off
set echo off
spool /home/oracle/CiscoPrimeV2/Scripts/upDotSlash.sql
select  'update csco_interface_avail_hour set interface_disp = '''||
        replace(interface_disp,'.','/')
        ||
        ''' where node = '''||node||''' and interface_disp = '''||interface_disp||''';'  linea     
from csco_interface_avail_hour
where regexp_instr(interface_disp,'[0-9][.][0-9]') != 0;
spool off
exit;
