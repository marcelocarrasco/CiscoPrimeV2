--
-- EHEALTH_STAT_IP_DAY
--
SELECT  TRUNC(FECHA)                          FECHA
        ,ELEMENT_ID
        ,ROUND(AVG(RECEIVEBYTES),2)           RECEIVEBYTES
        ,ROUND(AVG(SENDBYTES),2)              SENDBYTES
        ,ROUND(AVG(IFSPEED),2)                IFSPEED
        ,ROUND(AVG(RECEIVEDISCARDS),2)        RECEIVEDISCARDS
        ,ROUND(AVG(SENDDISCARDS),2)           SENDDISCARDS
        ,SUM(RECEIVEERRORS)                   RECEIVEERRORS
        ,SUM(SENDERRORS)                      SENDERRORS
        ,ROUND(AVG(RECEIVETOTALPKTRATE),2)    RECEIVETOTALPKTRATE
        ,ROUND(AVG(SENDTOTALPKTRATE),2)       SENDTOTALPKTRATE
        ,SUM(INQUEUEDROPS)                    INQUEUEDROPS
        ,SUM(OUTQUEUEDROPS)                   OUTQUEUEDROPS
        ,ROUND(AVG(UPPERCENT),2)              UPPERCENT
        ,SUM(SENDUTIL)                        SENDUTIL
        ,SUM(SENDTOTALPKTS)                   SENDTOTALPKTS
        ,ROUND(AVG(SENDUCASTPKTPERCENT),2)    SENDUCASTPKTPERCENT
        ,ROUND(AVG(SENDMCASTPKTPERCENT),2)    SENDMCASTPKTPERCENT
        ,ROUND(AVG(SENDBCASTPKTPERCENT),2)    SENDBCASTPKTPERCENT
        ,ROUND(AVG(SENDERRORPERCENT),2)       SENDERRORPERCENT
        ,ROUND(AVG(SENDDISCARDPERCENT),2)     SENDDISCARDPERCENT
        ,SUM(RECEIVEUTIL)                     RECEIVEUTIL
        ,ROUND(AVG(RECEIVETOTALPKTS),2)       RECEIVETOTALPKTS
        ,ROUND(AVG(RECEIVEUCASTPKTPERCENT),2) RECEIVEUCASTPKTPERCENT
        ,ROUND(AVG(RECEIVEMCASTPKTPERCENT),2) RECEIVEMCASTPKTPERCENT
        ,ROUND(AVG(RECEIVEBCASTPKTPERCENT),2) RECEIVEBCASTPKTPERCENT
        ,ROUND(AVG(RECEIVEERRORPERCENT),2)    RECEIVEERRORPERCENT
        ,ROUND(AVG(RECEIVEDISCARDPERCENT),2)  RECEIVEDISCARDPERCENT
        ,ROUND(AVG(SENDBCASTPKTRATE),2)       SENDBCASTPKTRATE
        ,ROUND(AVG(RECEIVEBCASTPKTRATE),2)    RECEIVEBCASTPKTRATE
FROM EHEALTH_STAT_IP_HOUR
--WHERE TO_CHAR(FECHA,'DD.MM.YYYY') = '20.08.2016'
WHERE FECHA BETWEEN TO_DATE('20.08.2016' , 'DD.MM.YYYY')
                 AND TO_DATE('20.08.2016' , 'DD.MM.YYYY') + 86399/86400
GROUP BY TRUNC(FECHA),ELEMENT_ID;
--
-- EHEALTH_STAT_IP_IBHW
--
WITH  OBJETOS_EHEALTH AS  (SELECT /*+ MATERIALIZE */
                                  ELEMENT_ID
                          FROM  EHEALTH_OBJECTS
                          WHERE FLAG_ENABLED = 'S'
                          AND GRUPO != 'IPRAN'),
      MAX_SENDBYTES AS  (SELECT FECHA,
                                ELEMENT_ID||','||FECHA ELEMENT_ID_FECHA,
                                ELEMENT_ID,
                                SENDBYTES
                        FROM (SELECT  FECHA,
                                      ELEMENT_ID,
                                      SENDBYTES,
                                      ROW_NUMBER() OVER( PARTITION BY ELEMENT_ID,TRUNC(FECHA) ORDER BY SENDBYTES DESC) RN
                              FROM (SELECT /*+ MATERIALIZE */
                                            ESIBH.FECHA,
                                            ESIBH.ELEMENT_ID,
                                            ESIBH.SENDBYTES,
                                            ROW_NUMBER() OVER( PARTITION BY ESIBH.ELEMENT_ID ORDER BY ESIBH.SENDBYTES DESC) RNK 
                                            
                                    FROM  EHEALTH_STAT_IP_BH ESIBH--,
                                          --OBJETOS_EHEALTH EO
                                    WHERE FECHA BETWEEN TO_DATE('20.08.2016','DD.MM.YYYY')
                                                AND TO_DATE('23.08.2016', 'DD.MM.YYYY') + 86399/86400
                                    --AND ESIBH.ELEMENT_ID = EO.ELEMENT_ID
                                    )
                              WHERE RNK = 1
                              ORDER BY 3 DESC)
                        WHERE RN = 1),
      MAX_RECEIVEBYTES AS (SELECT FECHA,
                                  ELEMENT_ID||','||FECHA ELEMENT_ID_FECHA,
                                  ELEMENT_ID,
                                  RECEIVEBYTES
                          FROM (SELECT  FECHA,
                                        ELEMENT_ID,
                                        RECEIVEBYTES,
                                        ROW_NUMBER() OVER( PARTITION BY ELEMENT_ID,TRUNC(FECHA) ORDER BY RECEIVEBYTES DESC) RN
                                FROM (SELECT /*+ MATERIALIZE */
                                              ESIBH.FECHA,
                                              ESIBH.ELEMENT_ID,
                                              ESIBH.RECEIVEBYTES,
                                              ROW_NUMBER() OVER( PARTITION BY ESIBH.ELEMENT_ID ORDER BY ESIBH.RECEIVEBYTES DESC) RNK 
                                              
                                      FROM  EHEALTH_STAT_IP_BH ESIBH--,
                                            --OBJETOS_EHEALTH EO
                                      WHERE FECHA BETWEEN TO_DATE('20.08.2016','DD.MM.YYYY')
                                                  AND TO_DATE('23.08.2016', 'DD.MM.YYYY') + 86399/86400
                                      --AND ESIH.ELEMENT_ID = EO.ELEMENT_ID
                                      )
                                WHERE RNK = 1
                                ORDER BY 3 DESC)
                          WHERE RN = 1),
      PARES_ELEMENT_ID_FECHA  AS  (SELECT  CASE
                                            WHEN  MAX_SENDBYTES.SENDBYTES > MAX_RECEIVEBYTES.RECEIVEBYTES  THEN  MAX_SENDBYTES.ELEMENT_ID_FECHA
                                            WHEN  MAX_SENDBYTES.SENDBYTES < MAX_RECEIVEBYTES.RECEIVEBYTES  THEN  MAX_RECEIVEBYTES.ELEMENT_ID_FECHA
                                            ELSE  MAX_SENDBYTES.ELEMENT_ID_FECHA
                                          END ELEMENT_ID_FECHA
                                  FROM  MAX_SENDBYTES,
                                        MAX_RECEIVEBYTES
                                  WHERE MAX_SENDBYTES.ELEMENT_ID = MAX_RECEIVEBYTES.ELEMENT_ID
                                  AND   MAX_SENDBYTES.FECHA = MAX_RECEIVEBYTES.FECHA)
  SELECT ELEMENT_ID_FECHA FROM PARES_ELEMENT_ID_FECHA;

--
-- EHEALTH_STAT_IP_BH
--
/*
Tomar el max entre RECEIVEBYTES y SENDBYTES como pivote para determinar que colunma manda para cada ELEMENT_ID validado
contra la EHEALTH_OBJECTS
*/

WITH  OBJETOS_EHEALTH AS  (SELECT /*+ MATERIALIZE */
                                  ELEMENT_ID
                          FROM  EHEALTH_OBJECTS
                          WHERE FLAG_ENABLED = 'S'
                          AND GRUPO != 'IPRAN'),
      MAX_SENDBYTES AS  (SELECT FECHA,
                                ELEMENT_ID||','||FECHA ELEMENT_ID_FECHA,
                                ELEMENT_ID,
                                SENDBYTES
                        FROM (SELECT  FECHA,
                                      ELEMENT_ID,
                                      SENDBYTES,
                                      ROW_NUMBER() OVER( PARTITION BY ELEMENT_ID,TRUNC(FECHA) ORDER BY SENDBYTES DESC) RN
                              FROM (SELECT /*+ MATERIALIZE */
                                            ESIH.FECHA,
                                            ESIH.ELEMENT_ID,
                                            ESIH.SENDBYTES,
                                            ROW_NUMBER() OVER( PARTITION BY ESIH.ELEMENT_ID,ESIH.FECHA ORDER BY ESIH.SENDBYTES DESC) RNK 
                                            
                                    FROM  EHEALTH_STAT_IP_HOUR ESIH,
                                          OBJETOS_EHEALTH EO
                                    WHERE TO_CHAR(FECHA,'DD.MM.YYYY') = '23.08.2016'
                                    AND ESIH.ELEMENT_ID = EO.ELEMENT_ID
                                    )
                              WHERE RNK = 1
                              ORDER BY 3 DESC)
                        WHERE RN = 1),
      MAX_RECEIVEBYTES AS (SELECT FECHA,
                                  ELEMENT_ID||','||FECHA ELEMENT_ID_FECHA,
                                  ELEMENT_ID,
                                  RECEIVEBYTES
                          FROM (SELECT  FECHA,
                                        ELEMENT_ID,
                                        RECEIVEBYTES,
                                        ROW_NUMBER() OVER( PARTITION BY ELEMENT_ID,TRUNC(FECHA) ORDER BY RECEIVEBYTES DESC) RN
                                FROM (SELECT /*+ MATERIALIZE */
                                              ESIH.FECHA,
                                              ESIH.ELEMENT_ID,
                                              ESIH.RECEIVEBYTES,
                                              ROW_NUMBER() OVER( PARTITION BY ESIH.ELEMENT_ID,ESIH.FECHA ORDER BY ESIH.RECEIVEBYTES DESC) RNK 
                                              
                                      FROM  EHEALTH_STAT_IP_HOUR ESIH,
                                            OBJETOS_EHEALTH EO
                                      WHERE TO_CHAR(FECHA,'DD.MM.YYYY') = '23.08.2016'
                                      AND ESIH.ELEMENT_ID = EO.ELEMENT_ID
                                      )
                                WHERE RNK = 1
                                ORDER BY 3 DESC)
                          WHERE RN = 1),
      PARES_ELEMENT_ID_FECHA  AS  (SELECT  CASE
                                            WHEN  MAX_SENDBYTES.SENDBYTES > MAX_RECEIVEBYTES.RECEIVEBYTES  THEN  MAX_SENDBYTES.ELEMENT_ID_FECHA
                                            WHEN  MAX_SENDBYTES.SENDBYTES < MAX_RECEIVEBYTES.RECEIVEBYTES  THEN  MAX_RECEIVEBYTES.ELEMENT_ID_FECHA
                                            ELSE  MAX_SENDBYTES.ELEMENT_ID_FECHA
                                          END ELEMENT_ID_FECHA
                                  FROM  MAX_SENDBYTES,
                                        MAX_RECEIVEBYTES
                                  WHERE MAX_SENDBYTES.ELEMENT_ID = MAX_RECEIVEBYTES.ELEMENT_ID
                                  AND   MAX_SENDBYTES.FECHA = MAX_RECEIVEBYTES.FECHA)
  SELECT ELEMENT_ID_FECHA FROM PARES_ELEMENT_ID_FECHA;
  
  
  
--
-- EHEALTH_STAT_IP_HOUR
--
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
                                                             AND DEO.INTERFACE_NAME  = CIH.INTERFAZ)
                            JOIN  CSCO_INTERFACE_AVAIL_HOUR CIA ON (CIH.FECHA = CIA.FECHA 
                                                                    AND CIH.NODE = CIA.NODE 
                                                                    AND CIH.INTERFAZ = CIA.INTERFACE_DISP)
                            JOIN  CSCO_INTERFACE_ERRORS_HOUR  CIE ON  (CIA.FECHA  = CIE.FECHA
                                                                      AND CIA.NODE  = CIE.NODE
                                                                      AND CIA.INTERFACE_DISP  = CIE.IFEXTIFDESCR)
                            WHERE TRUNC(CIH.FECHA) = TRUNC(SYSDATE-1)-- Procesa solo el dia de ayer
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


