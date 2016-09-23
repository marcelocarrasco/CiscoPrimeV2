

select 'create public synonym '||table_name||' for MCARRASCO.'||table_name||';'
from user_tables
where table_name like 'CSCO_%';



--create public synonym CSCO_MEMORY_BH for MCARRASCO.CSCO_MEMORY_BH;
--create public synonym CSCO_MEMORY_DAY for MCARRASCO.CSCO_MEMORY_DAY;
--create public synonym CSCO_MEMORY_IBHW for MCARRASCO.CSCO_MEMORY_IBHW;
create public synonym CSCO_CGN_STATS_BH for MCARRASCO.CSCO_CGN_STATS_BH;
create public synonym CSCO_CGN_STATS_DAY for MCARRASCO.CSCO_CGN_STATS_DAY;
create public synonym CSCO_CGN_STATS_HOUR for MCARRASCO.CSCO_CGN_STATS_HOUR;
create public synonym CSCO_CGN_STATS_IBHW for MCARRASCO.CSCO_CGN_STATS_IBHW;
create public synonym CSCO_CPU_DEVICE_AVG_HOUR for MCARRASCO.CSCO_CPU_DEVICE_AVG_HOUR;
--create public synonym CSCO_CPU_HOUR for MCARRASCO.CSCO_CPU_HOUR;
create public synonym CSCO_CPU_MEM_DEVICE_AVG_BH for MCARRASCO.CSCO_CPU_MEM_DEVICE_AVG_BH;
create public synonym CSCO_CPU_MEM_DEVICE_AVG_DAY for MCARRASCO.CSCO_CPU_MEM_DEVICE_AVG_DAY;
create public synonym CSCO_CPU_MEM_DEVICE_AVG_HOUR for MCARRASCO.CSCO_CPU_MEM_DEVICE_AVG_HOUR;
create public synonym CSCO_CPU_MEM_DEVICE_AVG_IBHW for MCARRASCO.CSCO_CPU_MEM_DEVICE_AVG_IBHW;
create public synonym CSCO_DEVICE_LINKS for MCARRASCO.CSCO_DEVICE_LINKS;
create public synonym CSCO_DEVICE_LINKS_AUX for MCARRASCO.CSCO_DEVICE_LINKS_AUX;
create public synonym CSCO_INTERFACE_AVAIL_HOUR for MCARRASCO.CSCO_INTERFACE_AVAIL_HOUR;
create public synonym CSCO_INTERFACE_ERRORS_HOUR for MCARRASCO.CSCO_INTERFACE_ERRORS_HOUR;
create public synonym CSCO_INTERFACE_HOUR for MCARRASCO.CSCO_INTERFACE_HOUR;
create public synonym CSCO_INVENTORY for MCARRASCO.CSCO_INVENTORY;
create public synonym CSCO_INVENTORY_AUX for MCARRASCO.CSCO_INVENTORY_AUX;
create public synonym CSCO_MEMORY_DEVICE_AVG_HOUR for MCARRASCO.CSCO_MEMORY_DEVICE_AVG_HOUR;
--create public synonym CSCO_MEMORY_HOUR for MCARRASCO.CSCO_MEMORY_HOUR;


select 'grant select on '||table_name||' to lbazan;'
from user_tables
where table_name like '%_CGN_%';

--grant select on CSCO_MEMORY_BH to eginer;
--grant select on CSCO_MEMORY_DAY to eginer;
--grant select on CSCO_MEMORY_IBHW to eginer;
--grant select on CSCO_CGN_STATS_BH to eginer;
grant select on CSCO_CGN_STATS_IBHW to lbazan;
grant select on CSCO_CGN_STATS_HOUR to lbazan;
grant select on CSCO_CGN_STATS_DAY to lbazan;
grant select on CSCO_CGN_STATS_BH to lbazan;
--grant select on CSCO_CGN_STATS_DAY to eginer;
--grant select on CSCO_CGN_STATS_HOUR to eginer;
--grant select on CSCO_CGN_STATS_IBHW to eginer;
grant select on CSCO_CPU_DEVICE_AVG_HOUR to eginer;
--grant select on CSCO_CPU_HOUR to eginer;
grant select on CSCO_CPU_MEM_DEVICE_AVG_BH to eginer;
grant select on CSCO_CPU_MEM_DEVICE_AVG_DAY to eginer;
grant select on CSCO_CPU_MEM_DEVICE_AVG_HOUR to eginer;
grant select on CSCO_CPU_MEM_DEVICE_AVG_IBHW to eginer;
grant select on CSCO_DEVICE_LINKS to eginer;
grant select on CSCO_DEVICE_LINKS_AUX to eginer;
grant select on CSCO_INTERFACE_AVAIL_HOUR to eginer;
grant select on CSCO_INTERFACE_ERRORS_HOUR to eginer;
grant select on CSCO_INTERFACE_HOUR to eginer;
grant select on CSCO_INVENTORY to eginer;
grant select on CSCO_INVENTORY_AUX to eginer;
grant select on CSCO_MEMORY_DEVICE_AVG_HOUR to eginer;
--grant select on CSCO_MEMORY_HOUR to eginer;
--
--
select 'grant select on '||table_name||' to eginer;'
from user_tables
where table_name like 'EHEALTH_%';


grant select on EHEALTH_OBJECTS_AUX to eginer;
grant select on EHEALTH_OBJECTS to eginer;
grant select on EHEALTH_STAT_IP_IBHW to eginer;
grant select on EHEALTH_STAT_IP_HOUR to eginer;
grant select on EHEALTH_STAT_IP_DAY to eginer;
grant select on EHEALTH_STAT_IP_BH to eginer;
