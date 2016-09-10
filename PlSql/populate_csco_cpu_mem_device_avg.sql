
-- BH
--
INSERT INTO CSCO_CPU_MEM_DEVICE_AVG_BH (FECHA,NODE,CPUUTILMAX5MINDEVICEAVG,CPUUTILAVG5MINDEVICEAVG,CPUUTILMAX1MINDEVICEAVG,
                                      CPUUTILAVG1MINDEVICEAVG,USEDBYTESDEVICEAVG,FREEBYTESDEVICEAVG,AVGUTILDEVICEAVG,MAXUTILDEVICEAVG)
                                      

WITH  MAX_SENDBYTES AS  (SELECT NODE||','||FECHA|| NODE_FECHA,
                                NODE,
                                FECHA,
                                SENDBYTES
                        FROM (SELECT  FECHA,
                                      NODE,
                                      SENDBYTES,
                                      ROW_NUMBER() OVER( PARTITION BY NODE,TRUNC(FECHA) ORDER BY SENDBYTES DESC) RN
                              FROM (SELECT  /*+ MATERIALIZE */
                                            FECHA,
                                            NODE,
                                            SENDBYTES,
                                            ROW_NUMBER() OVER( PARTITION BY NODE,FECHA ORDER BY SENDBYTES DESC) RNK 
                                    FROM CSCO_INTERFACE_HOUR
                                    WHERE TO_CHAR(FECHA,'DD.MM.YYYY') = '23.08.2016'
                                  )
                              WHERE RNK = 1
                              ORDER BY SENDBYTES DESC)
                        WHERE RN = 1),
      MAX_RECEIVEBYTES AS (SELECT NODE||','||FECHA|| NODE_FECHA,
                                  NODE,
                                  FECHA,
                                  RECEIVEBYTES
                          FROM (SELECT  FECHA,
                                        NODE,
                                        RECEIVEBYTES,
                                        ROW_NUMBER() OVER( PARTITION BY NODE,TRUNC(FECHA) ORDER BY RECEIVEBYTES DESC) RN
                                FROM (SELECT  /*+ MATERIALIZE */
                                              FECHA,
                                              NODE,
                                              RECEIVEBYTES,
                                              ROW_NUMBER() OVER( PARTITION BY NODE,FECHA ORDER BY RECEIVEBYTES DESC) RNK 
                                      FROM CSCO_INTERFACE_HOUR
                                      WHERE TO_CHAR(FECHA,'DD.MM.YYYY') = '23.08.2016'
                                    )
                                WHERE RNK = 1
                                ORDER BY RECEIVEBYTES DESC)
                          WHERE RN = 1),
      PARES_NODE_FECHA  AS  (SELECT  CASE
                                      WHEN  MAX_SENDBYTES.SENDBYTES > MAX_RECEIVEBYTES.RECEIVEBYTES  THEN  MAX_SENDBYTES.NODE_FECHA
                                      WHEN  MAX_SENDBYTES.SENDBYTES < MAX_RECEIVEBYTES.RECEIVEBYTES  THEN  MAX_RECEIVEBYTES.NODE_FECHA
                                      ELSE  MAX_SENDBYTES.NODE_FECHA
                                    END NODE_FECHA
                            FROM  MAX_SENDBYTES,
                                  MAX_RECEIVEBYTES
                            WHERE MAX_SENDBYTES.NODE = MAX_RECEIVEBYTES.NODE
                            AND   MAX_SENDBYTES.FECHA = MAX_RECEIVEBYTES.FECHA)
SELECT NODE_FECHA FROM PARES_NODE_FECHA

SELECT  FECHA,
        CCDVAH.NODE NODE,
        CPUUTILMAX5MINDEVICEAVG,
        CPUUTILAVG5MINDEVICEAVG,
        CPUUTILMAX1MINDEVICEAVG,
        CPUUTILAVG1MINDEVICEAVG,
        USEDBYTESDEVICEAVG,
        FREEBYTESDEVICEAVG,
        AVGUTILDEVICEAVG,
        MAXUTILDEVICEAVG
FROM  CSCO_CPU_MEM_DEVICE_AVG_HOUR CCDVAH
WHERE (CCDVAH.NODE,CCDVAH.FECHA) = (('C1900-PD-02','23.08.2016 22:00:00'));,
('CF223-BR-03','23.08.2016 22:00:00'),
('CF223-BR-01','23.08.2016 22:00:00'),
('CO008-P-01','23.08.2016 20:00:00'),
('C1900-BR-03','23.08.2016 22:00:00'),
('ngry01rt33','23.08.2016 21:00:00'));	

--
-- OPCION 2
--
-- RECEIVEBYTES --
--
SELECT  '('''||NODE||''','''||FECHA||''')' NODE_FECHA,
        RECEIVEBYTES
FROM (SELECT  FECHA,
              NODE,
              RECEIVEBYTES,
              ROW_NUMBER() OVER( PARTITION BY NODE,TRUNC(FECHA) ORDER BY RECEIVEBYTES DESC) RN
      FROM (
          SELECT /*+ MATERIALIZE */
                  FECHA,
                  NODE,
                  RECEIVEBYTES,
                  ROW_NUMBER() OVER( PARTITION BY NODE,FECHA ORDER BY RECEIVEBYTES DESC) RNK 
                  
          FROM CSCO_INTERFACE_HOUR
          WHERE TO_CHAR(FECHA,'DD.MM.YYYY') = '23.08.2016'
          )
      WHERE RNK = 1
      ORDER BY 3 DESC)
WHERE RN = 1;
--
-- SENDBYTES --
--
SELECT  '('''||NODE||''','''||FECHA||''')' NODE_FECHA,
        SENDBYTES
FROM (SELECT  FECHA,
              NODE,
              SENDBYTES,
              ROW_NUMBER() OVER( PARTITION BY NODE,TRUNC(FECHA) ORDER BY SENDBYTES DESC) RN
      FROM (
          SELECT /*+ MATERIALIZE */
                  FECHA,
                  NODE,
                  SENDBYTES,
                  ROW_NUMBER() OVER( PARTITION BY NODE,FECHA ORDER BY SENDBYTES DESC) RNK 
                  
          FROM CSCO_INTERFACE_HOUR
          WHERE TO_CHAR(FECHA,'DD.MM.YYYY') = '23.08.2016'
          )
      WHERE RNK = 1
      ORDER BY 3 DESC)
WHERE RN = 1;
--
--


-- HOUR
INSERT INTO CSCO_CPU_MEM_DEVICE_AVG_HOUR
SELECT  CPU.FECHA,
        CPU.NODE,
        CPU.CPUUTILMAX5MINDEVICEAVG,
        CPU.CPUUTILAVG5MINDEVICEAVG,
        CPU.CPUUTILMAX1MINDEVICEAVG,
        CPU.CPUUTILAVG1MINDEVICEAVG,
        MEM.USEDBYTESDEVICEAVG,
        MEM.FREEBYTESDEVICEAVG,
        MEM.AVGUTILDEVICEAVG,
        MEM.MAXUTILDEVICEAVG
FROM  CSCO_CPU_DEVICE_AVG_HOUR CPU,
      CSCO_MEMORY_DEVICE_AVG_HOUR MEM
WHERE CPU.FECHA = MEM.FECHA (+)
AND CPU.NODE = MEM.NODE (+)
AND TO_CHAR(CPU.FECHA,'dd.mm.yyyy') = '28.07.2016';
--and cpu.node = 'TOR-LAN-S05';



--
-- DAY
--
--insert into csco_cpu_mem_device_avg_day
SELECT  TO_CHAR(FECHA,'dd.mm.yyyy') FECHA,
        NODE,
        ROUND(AVG(CPUUTILMAX5MINDEVICEAVG),2) CPUUTILMAX5MINDEVICEAVG,
        ROUND(AVG(CPUUTILAVG5MINDEVICEAVG),2) CPUUTILAVG5MINDEVICEAVG,
        ROUND(AVG(CPUUTILMAX1MINDEVICEAVG),2) CPUUTILMAX1MINDEVICEAVG,
        ROUND(AVG(CPUUTILAVG1MINDEVICEAVG),2) CPUUTILAVG1MINDEVICEAVG,
        ROUND(AVG(USEDBYTESDEVICEAVG),2)      USEDBYTESDEVICEAVG,
        ROUND(AVG(FREEBYTESDEVICEAVG),2)      FREEBYTESDEVICEAVG,
        ROUND(AVG(AVGUTILDEVICEAVG),2)        AVGUTILDEVICEAVG,
        ROUND(AVG(MAXUTILDEVICEAVG),2)        MAXUTILDEVICEAVG
FROM  CSCO_CPU_MEM_DEVICE_AVG_HOUR
WHERE TO_CHAR(FECHA,'dd.mm.yyyy') = '02.08.2016'
GROUP BY TO_CHAR(FECHA,'dd.mm.yyyy'),NODE;
