--
-- IBHW
--
/*

*/
WITH  OBJETOS_EHEALTH AS  (SELECT /*+ MATERIALIZE */
                                      ELEMENT_NAME
                              FROM  EHEALTH_OBJECTS
                              WHERE FLAG_ENABLED = 'S'
                              AND GRUPO != 'IPRAN')
SELECT  '14.08.2016'                            FECHA
        ,NODE
        ,ROUND(AVG(CPUUTILMAX5MINDEVICEAVG),2)  CPUUTILMAX5MINDEVICEAVG
        ,ROUND(AVG(CPUUTILAVG5MINDEVICEAVG),2)  CPUUTILAVG5MINDEVICEAVG
        ,ROUND(AVG(CPUUTILMAX1MINDEVICEAVG),2)  CPUUTILMAX1MINDEVICEAVG
        ,ROUND(AVG(CPUUTILAVG1MINDEVICEAVG),2)  CPUUTILAVG1MINDEVICEAVG
        ,ROUND(AVG(USEDBYTESDEVICEAVG),2)       USEDBYTESDEVICEAVG
        ,ROUND(AVG(FREEBYTESDEVICEAVG),2)       FREEBYTESDEVICEAVG
        ,ROUND(AVG(AVGUTILDEVICEAVG),2)         AVGUTILDEVICEAVG
        ,ROUND(AVG(MAXUTILDEVICEAVG),2)         MAXUTILDEVICEAVG
FROM  (SELECT TRUNC(FECHA,'DAY') FECHA
              ,NODE
              ,CPUUTILMAX5MINDEVICEAVG
              ,CPUUTILAVG5MINDEVICEAVG
              ,CPUUTILMAX1MINDEVICEAVG
              ,CPUUTILAVG1MINDEVICEAVG
              ,USEDBYTESDEVICEAVG
              ,FREEBYTESDEVICEAVG
              ,AVGUTILDEVICEAVG
              ,MAXUTILDEVICEAVG                 
              ,ROW_NUMBER() OVER (PARTITION BY TRUNC(FECHA,'DAY'),
                                             NODE
                                    ORDER BY CPUUTILMAX5MINDEVICEAVG
                                    ,TRUNC(FECHA,'DAY') DESC NULLS LAST) SEQNUM
      FROM  CSCO_CPU_MEM_DEVICE_AVG_BH CCMDABH,
            OBJETOS_EHEALTH OE
      WHERE CCMDABH.NODE = OE.ELEMENT_NAME
      )
WHERE SEQNUM <= 3
AND TRUNC(FECHA) BETWEEN TO_DATE('14.08.2016', 'DD.MM.YYYY')
                       AND TO_DATE('20.08.2016', 'DD.MM.YYYY') + 86399/86400
GROUP BY FECHA,NODE;  

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
WITH  SENDBYTES AS  (SELECT /*+ MATERIALIZE */
                            FECHA,
                            NODE,
                            MAX(SENDBYTES) AS SENDBYTES_MAX
                    FROM CSCO_INTERFACE_HOUR
                    WHERE TO_CHAR(FECHA,'DD.MM.YYYY') = '02.08.2016'
                    GROUP BY FECHA,NODE
                    ORDER BY SENDBYTES_MAX DESC),
      RECEIVEBYTES AS (SELECT /*+ MATERIALIZE */
                              FECHA,
                              NODE,
                              MAX(RECEIVEBYTES) AS RECEIVEBYTES_MAX
                      FROM CSCO_INTERFACE_HOUR
                      WHERE TO_CHAR(FECHA,'DD.MM.YYYY') = '02.08.2016'
                      GROUP BY FECHA,NODE
                      ORDER BY  RECEIVEBYTES_MAX DESC),
      MAX_SENDBYTES AS  (SELECT FECHA,
                                NODE,
                                SENDBYTES_MAX
                        FROM  SENDBYTES
                        WHERE ROWNUM = 1),
      MAX_RECEIVEBYTES  AS  (SELECT FECHA,
                                    NODE,
                                    RECEIVEBYTES_MAX
                            FROM  RECEIVEBYTES
                            WHERE ROWNUM = 1)
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
WHERE CCDVAH.NODE = (SELECT  CASE
                              WHEN  MAX_SENDBYTES.SENDBYTES_MAX > MAX_RECEIVEBYTES.RECEIVEBYTES_MAX  THEN  MAX_SENDBYTES.NODE
                              WHEN  MAX_SENDBYTES.SENDBYTES_MAX < MAX_RECEIVEBYTES.RECEIVEBYTES_MAX  THEN  MAX_RECEIVEBYTES.NODE
                              ELSE  MAX_SENDBYTES.NODE
                            END NODE
                    FROM  MAX_SENDBYTES,
                          MAX_RECEIVEBYTES)
AND CCDVAH.FECHA = (SELECT  CASE
                              WHEN  MAX_SENDBYTES.SENDBYTES_MAX > MAX_RECEIVEBYTES.RECEIVEBYTES_MAX  THEN  MAX_SENDBYTES.FECHA
                              WHEN  MAX_SENDBYTES.SENDBYTES_MAX < MAX_RECEIVEBYTES.RECEIVEBYTES_MAX  THEN  MAX_RECEIVEBYTES.FECHA
                              ELSE  MAX_SENDBYTES.FECHA
                            END FECHA
                    FROM  MAX_SENDBYTES,
                          MAX_RECEIVEBYTES)
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
WITH  OBJETOS_EHEALTH AS  (SELECT /*+ MATERIALIZE */
                                      ELEMENT_NAME
                              FROM  EHEALTH_OBJECTS
                              WHERE FLAG_ENABLED = 'S'
                              AND GRUPO != 'IPRAN'
                              GROUP BY ELEMENT_NAME),
      CPU_MEM_DEVICE_AVG_DATA AS (SELECT  CPU.FECHA,
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
                                  WHERE CPU.FECHA = MEM.FECHA
                                  AND CPU.NODE = MEM.NODE)
SELECT  FECHA,
        NODE,
        CPUUTILMAX5MINDEVICEAVG,
        CPUUTILAVG5MINDEVICEAVG,
        CPUUTILMAX1MINDEVICEAVG,
        CPUUTILAVG1MINDEVICEAVG,
        USEDBYTESDEVICEAVG,
        FREEBYTESDEVICEAVG,
        AVGUTILDEVICEAVG,
        MAXUTILDEVICEAVG
FROM  OBJETOS_EHEALTH,
      CPU_MEM_DEVICE_AVG_DATA
WHERE ELEMENT_NAME = NODE;



--AND CPU.NODE = OE.ELEMENT_NAME
--AND TO_CHAR(CPU.FECHA,'DD.MM.YYYY') = TO_CHAR(SYSDATE-18,'DD.MM.YYYY');
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
