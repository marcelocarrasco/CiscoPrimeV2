--**********************************************************--
-- Elimina duplicados de la tabla CSCO_INTERFACE_AVAIL_HOUR
--**********************************************************--
DELETE 
--select *
FROM CSCO_INTERFACE_AVAIL_HOUR
WHERE ROWID IN (SELECT RID 
                FROM (SELECT  ROWID RID,
                              FECHA,
                              NODE,
                              INTERFACE_DISP,
                              ROW_NUMBER() OVER(PARTITION BY  FECHA,
                                                              NODE,
                                                              INTERFACE_DISP 
                                                ORDER BY  FECHA,
                                                          NODE,
                                                          INTERFACE_DISP) RN
                      FROM CSCO_INTERFACE_AVAIL_HOUR
                      WHERE TRUNC(FECHA) = '21.08.2016')
                WHERE RN > 1
               );

--**********************************************************--
-- Elimina duplicados de la tabla CSCO_INTERFACE_HOUR
--**********************************************************--
DELETE 
--select *
FROM CSCO_INTERFACE_HOUR
WHERE ROWID IN (SELECT RID 
                FROM (SELECT  ROWID RID,
                              FECHA,
                              NODE,
                              INTERFAZ,
                              ROW_NUMBER() OVER(PARTITION BY  FECHA,
                                                              NODE,
                                                              INTERFAZ 
                                                ORDER BY  FECHA,
                                                          NODE,
                                                          INTERFAZ) RN
                      FROM CSCO_INTERFACE_HOUR
                      WHERE TRUNC(FECHA) = '21.08.2016')
                WHERE RN > 1
               ); 
               
--**********************************************************--
-- Elimina duplicados de la tabla CSCO_INTERFACE_ERRORS_HOUR
--**********************************************************--
DELETE 
--select *
FROM CSCO_INTERFACE_ERRORS_HOUR
WHERE ROWID IN (SELECT RID 
                FROM (SELECT  ROWID RID,
                              FECHA,
                              NODE,
                              IFEXTIFDESCR,
                              ROW_NUMBER() OVER(PARTITION BY  FECHA,
                                                              NODE,
                                                              IFEXTIFDESCR 
                                                ORDER BY  FECHA,
                                                          NODE,
                                                          IFEXTIFDESCR) RN
                      FROM CSCO_INTERFACE_ERRORS_HOUR
                      WHERE TRUNC(FECHA) = '21.08.2016')
                WHERE RN > 1
               );
               
--**********************************************************--
-- Elimina duplicados de la tabla CSCO_CGN_STATS_HOUR
--**********************************************************--
DELETE 
--select *
FROM CSCO_CGN_STATS_HOUR
WHERE ROWID IN (SELECT RID 
                FROM (SELECT  ROWID RID,
                              FECHA,
                              NODE,
                              CGNINSTANCEID,
                              ROW_NUMBER() OVER(PARTITION BY  FECHA,
                                                              NODE,
                                                              CGNINSTANCEID 
                                                ORDER BY  FECHA,
                                                          NODE,
                                                          CGNINSTANCEID) RN
                      FROM CSCO_CGN_STATS_HOUR
                      WHERE TRUNC(FECHA) = '21.08.2016')
                WHERE RN > 1
               );
--**********************************************************--
-- Elimina duplicados de la tabla CSCO_CPU_DEVICE_AVG_HOUR
--**********************************************************--
DELETE 
--select *
FROM CSCO_CPU_DEVICE_AVG_HOUR
WHERE ROWID IN (SELECT RID 
                FROM (SELECT  ROWID RID,
                              FECHA,
                              NODE,
                              ROW_NUMBER() OVER(PARTITION BY  FECHA,
                                                              NODE 
                                                ORDER BY  FECHA,
                                                          NODE) RN
                      FROM CSCO_CPU_DEVICE_AVG_HOUR)
                      --WHERE TRUNC(FECHA) = '21.08.2016')
                WHERE RN > 1
               );
--**********************************************************--
-- Elimina duplicados de la tabla CSCO_MEMORY_DEVICE_AVG_HOUR
--**********************************************************--
DELETE 
--select *
FROM CSCO_MEMORY_DEVICE_AVG_HOUR
WHERE ROWID IN (SELECT RID 
                FROM (SELECT  ROWID RID,
                              FECHA,
                              NODE,
                              ROW_NUMBER() OVER(PARTITION BY  FECHA,
                                                              NODE 
                                                ORDER BY  FECHA,
                                                          NODE) RN
                      FROM CSCO_MEMORY_DEVICE_AVG_HOUR)
                      --WHERE TRUNC(FECHA) = '21.08.2016')
                WHERE RN > 1
               );