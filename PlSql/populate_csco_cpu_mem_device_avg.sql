
-- BH
--
SELECT  FECHA.
        NODE.
        CPUUTILMAX5MINDEVICEAVG.
        CPUUTILAVG5MINDEVICEAVG.
        CPUUTILMAX1MINDEVICEAVG.
        CPUUTILAVG1MINDEVICEAVG.
        USEDBYTESDEVICEAVG.
        FREEBYTESDEVICEAVG.
        AVGUTILDEVICEAVG.
        MAXUTILDEVICEAVG
FROM  (--TOMAR MAXIMO VALOR ENTRE SENDBYTES O RECEIVEBYTES		
      SELECT  to_char(FECHA,'dd.mm.yyyy HH24:MI') FECHA,
              NODE,
              CPUUTILMAX5MINDEVICEAVG,
              CPUUTILAVG5MINDEVICEAVG,
              CPUUTILMAX1MINDEVICEAVG,
              CPUUTILAVG1MINDEVICEAVG,
              USEDBYTESDEVICEAVG,
              FREEBYTESDEVICEAVG,
              AVGUTILDEVICEAVG,
              MAXUTILDEVICEAVG,                 
              ROW_NUMBER()  OVER (PARTITION BY  TRUNC(FECHA,'DAY'),
                                                NODE
                            ORDER BY trunc(FECHA) DESC,
                                     NODE DESC NULLS LAST) SEQNUM
            FROM CSCO_CPU_MEM_DEVICE_AVG_HOUR
            WHERE trunc(FECHA) = TO_DATE(P_FECHA,'dd.mm.yyyy')
    )
    WHERE SEQNUM = 1;



-- HOUR
INSERT INTO csco_cpu_mem_device_avg_hour
select  cpu.FECHA,
        cpu.NODE,
        cpu.CPUUTILMAX5MINDEVICEAVG,
        cpu.CPUUTILAVG5MINDEVICEAVG,
        cpu.CPUUTILMAX1MINDEVICEAVG,
        cpu.CPUUTILAVG1MINDEVICEAVG,
        mem.USEDBYTESDEVICEAVG,
        mem.FREEBYTESDEVICEAVG,
        mem.AVGUTILDEVICEAVG,
        mem.MAXUTILDEVICEAVG
from  csco_cpu_device_avg_hour cpu,
      csco_memory_device_avg_hour mem
where cpu.fecha = mem.fecha
and cpu.node = mem.node
and cpu.node = 'TOR-LAN-S05';



--
-- DAY
--
--insert into csco_cpu_mem_device_avg_day
select  FECHA,
        NODE,
        ROUND(AVG(CPUUTILMAX5MINDEVICEAVG),2) CPUUTILMAX5MINDEVICEAVG,
        ROUND(AVG(CPUUTILAVG5MINDEVICEAVG),2) CPUUTILAVG5MINDEVICEAVG,
        ROUND(AVG(CPUUTILMAX1MINDEVICEAVG),2) CPUUTILMAX1MINDEVICEAVG,
        ROUND(AVG(CPUUTILAVG1MINDEVICEAVG),2) CPUUTILAVG1MINDEVICEAVG,
        ROUND(AVG(USEDBYTESDEVICEAVG),2)      USEDBYTESDEVICEAVG,
        ROUND(AVG(FREEBYTESDEVICEAVG),2)      FREEBYTESDEVICEAVG,
        ROUND(AVG(AVGUTILDEVICEAVG),2)        AVGUTILDEVICEAVG,
        ROUND(AVG(MAXUTILDEVICEAVG),2)        MAXUTILDEVICEAVG
from  csco_cpu_mem_device_avg_hour
--where node = 'AMB037-AGG-03'
group by fecha,node
order by fecha;



