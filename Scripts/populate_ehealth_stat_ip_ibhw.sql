
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
FROM    DATOS_INTERFACES