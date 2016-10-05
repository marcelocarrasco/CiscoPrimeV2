CREATE OR REPLACE PACKAGE G_CISCO_PRIME AS 

  /**
  * Author: Carrasco Marcelo mailto: mcarrasco@harriague.com
  * Date: 13/05/2016
  * Comment: Paquete para conter la funcionalidad asociada a CISCO PRIME.
  */
  
  /**
  * Constant: limit_in, numero máximo de filas por iteracion en los bulk collect.
  */
  limit_in    pls_integer := 100;
  
  /**
  * Constant: limit_prom, cantidad de valores promedio a tomar en cuenta para calcular BH (Busy Hour).
  */
  limit_prom  pls_integer := 3;
  
  /**
  * Function: F_GET_LINK, extrae los datos necesarios para armar links del tipo, Equipo A <--> Equipo B.
  * Param: P_LINEA, línea que contiene los datos necesarios para armar el link.
  */
  FUNCTION F_GET_LINK (p_linea IN VARCHAR2) RETURN VARCHAR2;
  
  /**
  *
  */
  PROCEDURE P_INVENTORY_INS(P_FECHA IN VARCHAR2);
  /**
  * Procedure: P_CGN_STATS_DAY_INS, calcula la sumarización de los contadores a nivel de día.
  * Param: P_FECHA_DESDE, P_FECHA_HASTA, rango de fechas para hacer la sumarización.
  */
  --******************************************************--
  --                        CGN_STATS                     --
  --******************************************************--
  PROCEDURE P_CGN_STATS_DAY_INS(p_fecha_desde in varchar2, p_fecha_hasta in varchar2);
  
  /**
  * Proedure: P_CGN_STATS_BH_INS, calcula la Busy Hour (BH).
  * Param: P_FECHA_DESDE, P_FECHA_HASTA, rango de fechas para calcular la BH.
  */
  PROCEDURE P_CGN_STATS_BH_INS(p_fecha_desde in varchar2, p_fecha_hasta in varchar2);
  
  /**
  * Procedure: P_CGN_STATS_IBHW_INS, calcula la Isa Busy Hour Week (IBHW)
  * Param: P_FECHA_DESDE, P_FECHA_HASTA, rango de fechas para calcular la IBHW.
  */
  PROCEDURE P_CGN_STATS_IBHW_INS(p_fecha_desde in varchar2, p_fecha_hasta in varchar2);
  /**
  *
  */
  PROCEDURE P_CALC_SUM_CGN_STATS(P_FECHA IN VARCHAR2);
  --******************************************************--
  --                CSCO_CPU_MEM_DEVICE_AVG               --
  --******************************************************--
  /**
  *
  */
  PROCEDURE P_CSCO_CPU_MEM_DEVICE_AVG_DAY(P_FECHA_DESDE IN VARCHAR2,P_FECHA_HASTA IN VARCHAR2);
 /**
 *
 */
  PROCEDURE P_CSCO_CPU_MEM_DEVICE_AVG_BH(P_FECHA_DESDE IN VARCHAR2,P_FECHA_HASTA IN VARCHAR2);
  /**
  *
  */
  PROCEDURE P_CSCO_CPU_MEM_DEVICE_AVG_IBHW(P_FECHA_DESDE IN VARCHAR2,P_FECHA_HASTA IN VARCHAR2);
  /**
  *
  */
  PROCEDURE P_CALC_SUM_CPU_MEM_DEVICE_AVG(P_FECHA IN VARCHAR2);
  --******************************************************--
  --                EHEALTH_STAT_IP                       --
  --******************************************************--
  /**
  *
  */
  PROCEDURE P_EHEALTH_STAT_IP_BH(P_FECHA_DESDE IN VARCHAR2,P_FECHA_HASTA IN VARCHAR2);
  /**
  *
  */
  PROCEDURE P_EHEALTH_STAT_IP_IBHW(P_FECHA_DESDE IN VARCHAR2,P_FECHA_HASTA IN VARCHAR2);
  /**
  *
  */
  PROCEDURE P_EHEALTH_STAT_IP_DAY(P_FECHA_DESDE IN VARCHAR2,P_FECHA_HASTA IN VARCHAR2);
  /**
  *
  */
  PROCEDURE P_CALC_SUM_EHEALTH_STAT_IP(P_FECHA IN VARCHAR2);
END G_CISCO_PRIME;
/


CREATE OR REPLACE PACKAGE BODY G_CISCO_PRIME AS

  FUNCTION F_GET_LINK (p_linea IN VARCHAR2) RETURN VARCHAR2
  AS
  
  v_origen_endPoint     VARCHAR2(255 CHAR); 
  v_origen_portNumber   VARCHAR2(255 CHAR);
  v_destino_endPoint    VARCHAR2(255 CHAR);
  v_destino_portNumber  VARCHAR2(255 CHAR);
  v_result              VARCHAR2(4000 CHAR);
  sql_stmt              VARCHAR2(32767 CHAR);
    
  BEGIN
    begin
    sql_stmt := 'SELECT substr(REGEXP_SUBSTR(''' || p_linea || ''',''(Key=[^)]*)'',1,1),5) ,
                    substr(REGEXP_SUBSTR(''' || p_linea || ''', ''(PortNumber=[A-Z a-z]*[0-9]*[/ 0-9]*)'',1,1),12) ,
                    substr(REGEXP_SUBSTR(''' || p_linea || ''', ''(Key=[^)]*)'',1,2),5) ,
                    substr(REGEXP_SUBSTR(''' || p_linea || ''', ''(PortNumber=[A-Z a-z]*[0-9]*[/ 0-9]*)'',1,2),12)
 
              FROM dual';             
              
    EXECUTE IMMEDIATE sql_stmt INTO v_origen_endPoint, v_origen_portNumber, v_destino_endPoint, v_destino_portNumber;
    
    IF  (v_origen_endPoint IS NOT NULL) AND
        (v_origen_portNumber IS NOT NULL) AND
        (v_destino_endPoint IS NOT NULL) AND
        (v_destino_portNumber IS NOT NULL) THEN
      v_result := v_origen_endPoint || ':' || v_origen_portNumber || ' <==> ' || v_destino_endPoint || ':' || v_destino_portNumber;
    ELSE
      v_result := null;
    END IF;
    
    EXCEPTION
      WHEN OTHERS THEN
        G_ERROR_LOG_NEW.P_LOG_ERROR('F_GET_LINK',
                                    SQLCODE,
                                    SQLERRM,
                                    'linea '||p_linea);
                                    
        v_result := 'ERROR:ERROR <==> ERROR:ERROR';
    end;
    RETURN v_result;
    --
  END F_GET_LINK;
  --**--**--
  PROCEDURE P_INVENTORY_INS(P_FECHA IN VARCHAR2) AS
  
    CURSOR INDX IS
    SELECT  ROWNUMBER,
            SUBSTR(LINEA,6,LENGTH(LINEA)) CLAVE,
            SUBSTR(VALOR,8,LENGTH(VALOR)) VALOR
    FROM CSCO_INVENTORY_AUX
    ORDER BY ROWNUMBER;
    TYPE INI_FIN IS RECORD(
      ROWNUMBER  NUMBER,
      CLAVE        VARCHAR2(30 CHAR),
      VALOR       VARCHAR2(4000 CHAR)
      );
    --
    TYPE CONTENEDOR IS TABLE OF VARCHAR2(2000 CHAR) INDEX BY VARCHAR2(30 CHAR);
    TYPE INI_FIN_TAB IS TABLE OF INI_FIN INDEX BY PLS_INTEGER;
    
    VINIFINTAB INI_FIN_TAB;
    VCONTENEDOR CONTENEDOR;
    
    VINDICE     VARCHAR2(30 CHAR) := '-';
    VINDICEFIN  VARCHAR2(30 CHAR) := 'InvestigationStateEnum';
    
  BEGIN
    G_ERROR_LOG_NEW.P_LOG_ERROR('P_INVENTORY_INS','0','NO ERROR','INICIO PROCESO DE COPIA DE INVENTARIO '||P_FECHA);
    
    EXECUTE IMMEDIATE 'TRUNCATE TABLE CSCO_INVENTORY';
    OPEN INDX;
    LOOP
    BEGIN
      FETCH INDX BULK COLLECT INTO VINIFINTAB LIMIT 1;--get 'CommunicationStateEnum';
      EXIT WHEN INDX%NOTFOUND;
      VCONTENEDOR('rownumber') := VINIFINTAB(1).ROWNUMBER;
      VCONTENEDOR(VINIFINTAB(1).CLAVE) := VINIFINTAB(1).VALOR;-- value of 'CommunicationStateEnum'
      VINDICE := 'CommunicationStateEnum';
      WHILE VINDICE != VINDICEFIN LOOP
        FETCH INDX BULK COLLECT INTO VINIFINTAB LIMIT 1;
        VCONTENEDOR(VINIFINTAB(1).CLAVE) := VINIFINTAB(1).VALOR;
        VINDICE := VINIFINTAB(1).CLAVE;
      END LOOP;
      INSERT INTO CSCO_INVENTORY (INVENTORY_ID,DEVICE,DEVICE_SERIES,ELEMENT_TYPE,IP_ADDRESS)
      VALUES (STANDARD_HASH(VCONTENEDOR('DeviceName'), 'MD5'),VCONTENEDOR('DeviceName'),SUBSTR(VCONTENEDOR('DeviceSerialNumber'),1,INSTR(VCONTENEDOR('DeviceSerialNumber'),' ',1)),VCONTENEDOR('ElementType'),VCONTENEDOR('IP'));
      EXCEPTION
            WHEN OTHERS THEN
              G_ERROR_LOG_NEW.P_LOG_ERROR('P_INVENTORY_INS',
                                        SQLCODE,
                                        SQLERRM,
                                        'Error al insertar datos, puede que falte alguna de las columnas necesarias. Ver fila :'||TO_CHAR(VCONTENEDOR('rownumber')));
    END;
    END LOOP;
    CLOSE INDX;
    COMMIT;
    G_ERROR_LOG_NEW.P_LOG_ERROR('P_INVENTORY_INS','0','NO ERROR','FIN PROCESO DE COPIA DE INVENTARIO '||P_FECHA);
    EXCEPTION
      WHEN OTHERS THEN
        G_ERROR_LOG_NEW.P_LOG_ERROR('P_INVENTORY_INS',
                                  SQLCODE,
                                  SQLERRM,
                                  'Error al ejecutar el procedimiento');
        
  END P_INVENTORY_INS;
  --**--**--
  PROCEDURE P_CGN_STATS_DAY_INS(p_fecha_desde IN VARCHAR2, p_fecha_hasta IN VARCHAR2) AS
  --
    TYPE t_cgn_stats_row IS TABLE OF csco_cgn_stats_day%rowtype;
    t_cgn_stats_tab t_cgn_stats_row;
    
    l_errors NUMBER;
    l_errno  NUMBER;
    l_msg    VARCHAR2(4000 CHAR);
    l_idx    NUMBER;
    CURSOR cur (fecha_desde VARCHAR2, fecha_hasta VARCHAR2) IS
    SELECT  trunc(csr.FECHA)                                 FECHA,
            csr.node                                         NODO,
            csr.cgninstanceid                                CGNINSTANCEID,
            round(nvl(AVG(csr.Activetranslations),0),2)      ACTIVETRANSLATIONS,
            round(nvl(AVG(csr.CREATERATE),0),2)              CREATERATE,
            round(nvl(AVG(csr.DELETERATE),0),2)              DELETERATE,
            round(nvl(AVG(csr.OUTSIDEFORWARDRATE),0),2)      OUTSIDEFORWARDRATE,
            round(nvl(AVG(csr.INSIDEFORWARDRATE),0),2)       INSIDEFORWARDRATE,
            round(nvl(AVG(csr.DROPSPORTLIMITEXCEEDED),0),2)  DROPSPORTLIMITEXCEEDED,
            round(nvl(AVG(csr.DROPSSYSTEMLIMITREACHED),0),2) DROPSSYSTEMLIMITREACHED,
            round(nvl(AVG(csr.DROPSRESOURCEDEPLETION),0),2)  DROPSRESOURCEDEPLETION,
            round(nvl(AVG(csr.NOTRANSLATIONENTRYDROPS),0),2) NOTRANSLATIONENTRYDROPS,
            round(nvl(AVG(csr.ADDRESSTOTALLYFREE),0),2)      ADDRESSTOTALLYFREE,
            round(nvl(AVG(csr.ADDRESSUSED),0),2)             ADDRESSUSED,
            round(nvl(AVG(csr.NUMBEROFSUBSCRIBERS),0),2)     NUMBEROFSUBSCRIBERS   
    FROM csco_CGN_STATS_HOUR csr
    WHERE trunc(csr.FECHA) BETWEEN TO_DATE(FECHA_DESDE,'DD.MM.YYYY')
    AND TO_DATE(FECHA_HASTA,'DD.MM.YYYY')
    GROUP BY trunc(csr.FECHA), csr.node, csr.cgninstanceid
    ORDER BY FECHA, nodo,cgninstanceid;
  --
  BEGIN

    OPEN cur(p_fecha_desde,p_fecha_hasta);
    LOOP
      FETCH cur BULK COLLECT INTO t_cgn_stats_tab LIMIT limit_in;
      BEGIN
        FORALL indice IN 1 .. t_cgn_stats_tab.COUNT SAVE EXCEPTIONS
          INSERT INTO CSCO_CGN_STATS_DAY VALUES t_cgn_stats_tab(indice);
        EXCEPTION
          WHEN OTHERS THEN
            L_ERRORS := SQL%BULK_EXCEPTIONS.COUNT;
            FOR indice_e IN 1 .. L_ERRORS
            LOOP
                L_ERRNO := SQL%BULK_EXCEPTIONS(indice_e).ERROR_CODE;
                L_MSG   := SQLERRM(-L_ERRNO);
                L_IDX   := SQL%BULK_EXCEPTIONS(indice_e).ERROR_INDEX;
                
                G_ERROR_LOG_NEW.P_LOG_ERROR('P_CGN_STATS_DAY_INS',
                                            l_errno,
                                            l_msg,
                                            'FECHA => '||t_cgn_stats_tab(l_idx).FECHA||
                                            ' NODE => '||t_cgn_stats_tab(l_idx).NODE||
                                            ' CGNINSTANCEID => '||t_cgn_stats_tab(l_idx).CGNINSTANCEID||
                                            ' ACTIVETRANSLATIONS => '||to_char(t_cgn_stats_tab(l_idx).ACTIVETRANSLATIONS)||
                                            ' CREATERATE => '||to_char(t_cgn_stats_tab(l_idx).CREATERATE)||
                                            ' DELETERATE => '||to_char(t_cgn_stats_tab(l_idx).DELETERATE)||
                                            ' OUTSIDEFORWARDRATE => '||to_char(t_cgn_stats_tab(l_idx).OUTSIDEFORWARDRATE)||
                                            ' INSIDEFORWARDRATE => '||to_char(t_cgn_stats_tab(l_idx).INSIDEFORWARDRATE)||
                                            ' DROPSPORTLIMITEXCEEDED => '||to_char(t_cgn_stats_tab(l_idx).DROPSPORTLIMITEXCEEDED)||
                                            ' DROPSSYSTEMLIMITREACHED => '||to_char(t_cgn_stats_tab(l_idx).DROPSSYSTEMLIMITREACHED)||
                                            ' DROPSRESOURCEDEPLETION => '||to_char(t_cgn_stats_tab(l_idx).DROPSRESOURCEDEPLETION)||
                                            ' NOTRANSLATIONENTRYDROPS => '||to_char(t_cgn_stats_tab(l_idx).NOTRANSLATIONENTRYDROPS)||
                                            ' ADDRESSTOTALLYFREE => '||to_char(t_cgn_stats_tab(l_idx).ADDRESSTOTALLYFREE)||
                                            ' ADDRESSUSED => '||to_char(t_cgn_stats_tab(l_idx).ADDRESSUSED)||
                                            ' NUMBEROFSUBSCRIBERS => '||to_char(t_cgn_stats_tab(l_idx).NUMBEROFSUBSCRIBERS));
      
            END LOOP;
      END;
      exit when cur%notfound;
    END loop;
    COMMIT;
    CLOSE cur;
    EXCEPTION
      WHEN OTHERS THEN
        G_ERROR_LOG_NEW.P_LOG_ERROR('P_CGN_STATS_DAY_INS',
                                    SQLCODE,
                                    SQLERRM,
                                    'P_FECHA_DESDE '||P_fecha_desde||' P_FECHA_HASTA => '||p_fecha_hasta);
  END P_CGN_STATS_DAY_INS;
  --**--**--
  PROCEDURE P_CGN_STATS_BH_INS(p_fecha_desde IN VARCHAR2, p_fecha_hasta IN VARCHAR2) AS
  --
    CURSOR cur(fecha_desde VARCHAR2, fecha_hasta VARCHAR2) IS
    SELECT  fecha,
        node,
        CGNINSTANCEID,
        activetranslations ,
        CREATERATE,
        DELETERATE,
        OUTSIDEFORWARDRATE,
        INSIDEFORWARDRATE,
        DROPSPORTLIMITEXCEEDED,
        DROPSSYSTEMLIMITREACHED,
        DROPSRESOURCEDEPLETION,
        NOTRANSLATIONENTRYDROPS,
        ADDRESSTOTALLYFREE,
        ADDRESSUSED,
        NUMBEROFSUBSCRIBERS
    FROM (
          SELECT to_char(fecha,'DD.MM.YYYY HH24') FECHA,
                 node,
                 CGNINSTANCEID,
                 ACTIVETRANSLATIONS ,
                 CREATERATE,
                  DELETERATE,
                  OUTSIDEFORWARDRATE,
                  INSIDEFORWARDRATE,
                  DROPSPORTLIMITEXCEEDED,
                  DROPSSYSTEMLIMITREACHED,
                  DROPSRESOURCEDEPLETION,
                  NOTRANSLATIONENTRYDROPS,
                  ADDRESSTOTALLYFREE,
                  ADDRESSUSED,
                  NUMBEROFSUBSCRIBERS,                 
                 ROW_NUMBER() OVER (PARTITION BY TRUNC(fecha),
                                                 node,
                                                 cgninstanceid
                                        ORDER BY (ACTIVETRANSLATIONS) DESC,
                                                 trunc(fecha) DESC NULLS LAST) SEQNUM
          FROM CSCO_CGN_STATS_HOUR
          WHERE TRUNC(FECHA) BETWEEN TO_DATE(FECHA_DESDE, 'DD.MM.YYYY')
                           AND TO_DATE(FECHA_HASTA, 'DD.MM.YYYY') + 86399/86400)
    WHERE SEQNUM = 1;
    --
    l_errors number;
    l_errno  number;
    l_msg    VARCHAR2(4000 CHAR);
    l_idx    number;
    --
    TYPE t_cgn_stats_bh_row IS TABLE OF csco_cgn_stats_bh%rowtype;
    t_cgn_stats_bh_tab t_cgn_stats_bh_row;
    --
  BEGIN
    EXECUTE IMMEDIATE 'alter session set nls_date_format = ''DD.MM.YYYY HH24:MI:SS''';
    OPEN cur(p_fecha_desde,p_fecha_hasta);
    LOOP
      FETCH cur BULK COLLECT INTO t_cgn_stats_bh_tab LIMIT limit_in;
      BEGIN
        FORALL indice IN 1 .. t_cgn_stats_bh_tab.COUNT SAVE EXCEPTIONS
          INSERT INTO csco_cgn_stats_bh values t_cgn_stats_bh_tab(indice);
        EXCEPTION
          WHEN OTHERS THEN
            L_ERRORS := SQL%BULK_EXCEPTIONS.COUNT;
            FOR indice IN 1 .. L_ERRORS
            LOOP
                L_ERRNO := SQL%BULK_EXCEPTIONS(indice).ERROR_CODE;
                L_MSG   := SQLERRM(-L_ERRNO);
                L_IDX   := SQL%BULK_EXCEPTIONS(indice).ERROR_INDEX;
                
                G_ERROR_LOG_NEW.P_LOG_ERROR('P_CGN_STATS_BH_INS',
                                            l_errno,
                                            L_MSG,
                                            'FECHA => '                     ||T_CGN_STATS_BH_TAB(L_IDX).FECHA||
                                            ' NODE => '                     ||T_CGN_STATS_BH_TAB(L_IDX).NODE||
                                            ' CGNINSTANCEID => '            ||T_CGN_STATS_BH_TAB(L_IDX).CGNINSTANCEID||
                                            ' ACTIVETRANSLATIONS => '       ||TO_CHAR(T_CGN_STATS_BH_TAB(L_IDX).ACTIVETRANSLATIONS)||
                                            ' CREATERATE => '               ||TO_CHAR(T_CGN_STATS_BH_TAB(L_IDX).CREATERATE)||
                                            ' DELETERATE => '               ||TO_CHAR(T_CGN_STATS_BH_TAB(L_IDX).DELETERATE)||
                                            ' OUTSIDEFORWARDRATE => '       ||TO_CHAR(T_CGN_STATS_BH_TAB(L_IDX).OUTSIDEFORWARDRATE)||
                                            ' INSIDEFORWARDRATE => '        ||TO_CHAR(T_CGN_STATS_BH_TAB(L_IDX).INSIDEFORWARDRATE)||
                                            ' DROPSPORTLIMITEXCEEDED => '   ||TO_CHAR(T_CGN_STATS_BH_TAB(L_IDX).DROPSPORTLIMITEXCEEDED)||
                                            ' DROPSSYSTEMLIMITREACHED => '  ||TO_CHAR(T_CGN_STATS_BH_TAB(L_IDX).DROPSSYSTEMLIMITREACHED)||
                                            ' DROPSRESOURCEDEPLETION => '   ||TO_CHAR(T_CGN_STATS_BH_TAB(L_IDX).DROPSRESOURCEDEPLETION)||
                                            ' NOTRANSLATIONENTRYDROPS => '  ||TO_CHAR(T_CGN_STATS_BH_TAB(L_IDX).NOTRANSLATIONENTRYDROPS)||
                                            ' ADDRESSTOTALLYFREE => '       ||TO_CHAR(T_CGN_STATS_BH_TAB(L_IDX).ADDRESSTOTALLYFREE)||
                                            ' ADDRESSUSED => '              ||TO_CHAR(T_CGN_STATS_BH_TAB(L_IDX).ADDRESSUSED)||
                                            ' NUMBEROFSUBSCRIBERS => '      ||TO_CHAR(T_CGN_STATS_BH_TAB(L_IDX).NUMBEROFSUBSCRIBERS));
      
            END LOOP;
      END;
      EXIT WHEN cur%NOTFOUND;
    END LOOP;
    COMMIT;
    CLOSE cur;
    
    EXCEPTION
      WHEN OTHERS THEN
        G_ERROR_LOG_NEW.P_LOG_ERROR('P_CGN_STATS_BH_INS',
                                    SQLCODE,
                                    SQLERRM,
                                    'P_FECHA_DESDE '||P_FECHA_DESDE||' P_FECHA_HASTA => '||P_FECHA_HASTA);
  END P_CGN_STATS_BH_INS;
  --**--**--
  PROCEDURE P_CGN_STATS_IBHW_INS(p_fecha_desde in varchar2, p_fecha_hasta in varchar2) as
  --
  CURSOR cur(fecha_desde varchar2, fecha_hasta varchar2) IS
  SELECT  fecha_desde                           FECHA,
          node,
          CGNINSTANCEID,
          ROUND(AVG(ACTIVETRANSLATIONS),2)      ACTIVETRANSLATIONS, 
          ROUND(AVG(CREATERATE),2)              CREATERATE ,
          ROUND(AVG(DELETERATE),2)              DELETERATE,
          ROUND(AVG(OUTSIDEFORWARDRATE),2)      OUTSIDEFORWARDRATE,
          ROUND(AVG(INSIDEFORWARDRATE),2)       INSIDEFORWARDRATE,
          ROUND(AVG(DROPSPORTLIMITEXCEEDED),2)  DROPSPORTLIMITEXCEEDED,
          ROUND(AVG(DROPSSYSTEMLIMITREACHED),2) DROPSSYSTEMLIMITREACHED,
          ROUND(AVG(DROPSRESOURCEDEPLETION),2)  DROPSRESOURCEDEPLETION,
          ROUND(AVG(NOTRANSLATIONENTRYDROPS),2) NOTRANSLATIONENTRYDROPS,
          ROUND(AVG(ADDRESSTOTALLYFREE),2)      ADDRESSTOTALLYFREE,
          ROUND(AVG(ADDRESSUSED),2)             ADDRESSUSED,
          ROUND(AVG(NUMBEROFSUBSCRIBERS),2)     NUMBEROFSUBSCRIBERS
  FROM (
        SELECT  TRUNC(FECHA,'DAY') FECHA,
                NODE,
                CGNINSTANCEID,
                ACTIVETRANSLATIONS,
                CREATERATE,
                DELETERATE,
                OUTSIDEFORWARDRATE,
                INSIDEFORWARDRATE,
                DROPSPORTLIMITEXCEEDED,
                DROPSSYSTEMLIMITREACHED,
                DROPSRESOURCEDEPLETION,
                NOTRANSLATIONENTRYDROPS,
                ADDRESSTOTALLYFREE,
                ADDRESSUSED,
                NUMBEROFSUBSCRIBERS,
                ROW_NUMBER() OVER (PARTITION BY TRUNC(FECHA,'DAY'),
                                                NODE,
                                                CGNINSTANCEID
                                      ORDER BY (ACTIVETRANSLATIONS) DESC,
                                               TRUNC(FECHA) DESC NULLS LAST) SEQNUM
        from CSCO_CGN_STATS_BH)--BH
  where SEQNUM <= LIMIT_PROM
  AND FECHA BETWEEN to_date(FECHA_DESDE,'DD.MM.YYYY') AND to_date(FECHA_HASTA,'DD.MM.YYYY')
  GROUP BY FECHA,NODE,CGNINSTANCEID;
  --
  l_errors number;
  l_errno  number;
  l_msg    varchar2(4000);
  l_idx    number;
  --
  TYPE t_cgn_stats_ibhw_row IS TABLE OF csco_cgn_stats_ibhw%rowtype;
  t_cgn_stats_ibhw_tab t_cgn_stats_ibhw_row;
  --
  begin
    OPEN cur(p_fecha_desde,p_fecha_hasta);
    LOOP
      FETCH cur bulk collect into t_cgn_stats_ibhw_tab limit limit_in;
      BEGIN
        FORALL indice IN 1 .. t_cgn_stats_ibhw_tab.COUNT SAVE EXCEPTIONS
          INSERT INTO csco_cgn_stats_ibhw values t_cgn_stats_ibhw_tab(indice);
        EXCEPTION
          WHEN OTHERS THEN
            L_ERRORS := SQL%BULK_EXCEPTIONS.COUNT;
            FOR indice IN 1 .. L_ERRORS
            LOOP
                L_ERRNO := SQL%BULK_EXCEPTIONS(indice).ERROR_CODE;
                L_MSG   := SQLERRM(-L_ERRNO);
                L_IDX   := SQL%BULK_EXCEPTIONS(indice).ERROR_INDEX;
                
                G_ERROR_LOG_NEW.P_LOG_ERROR('P_CGN_STATS_IBHW_INS',
                                            l_errno,
                                            l_msg,
                                            'FECHA => '                     ||T_CGN_STATS_IBHW_TAB(L_IDX).FECHA||
                                            ' NODE => '                     ||T_CGN_STATS_IBHW_TAB(L_IDX).NODE||
                                            ' CGNINSTANCEID => '            ||T_CGN_STATS_IBHW_TAB(L_IDX).CGNINSTANCEID||
                                            ' ACTIVETRANSLATIONS => '       ||TO_CHAR(T_CGN_STATS_IBHW_TAB(L_IDX).ACTIVETRANSLATIONS)||
                                            ' CREATERATE => '               ||TO_CHAR(T_CGN_STATS_IBHW_TAB(L_IDX).CREATERATE)||
                                            ' DELETERATE => '               ||TO_CHAR(T_CGN_STATS_IBHW_TAB(L_IDX).DELETERATE)||
                                            ' OUTSIDEFORWARDRATE => '       ||TO_CHAR(T_CGN_STATS_IBHW_TAB(L_IDX).OUTSIDEFORWARDRATE)||
                                            ' INSIDEFORWARDRATE => '        ||TO_CHAR(T_CGN_STATS_IBHW_TAB(L_IDX).INSIDEFORWARDRATE)||
                                            ' DROPSPORTLIMITEXCEEDED => '   ||TO_CHAR(T_CGN_STATS_IBHW_TAB(L_IDX).DROPSPORTLIMITEXCEEDED)||
                                            ' DROPSSYSTEMLIMITREACHED => '  ||TO_CHAR(T_CGN_STATS_IBHW_TAB(L_IDX).DROPSSYSTEMLIMITREACHED)||
                                            ' DROPSRESOURCEDEPLETION => '   ||TO_CHAR(T_CGN_STATS_IBHW_TAB(L_IDX).DROPSRESOURCEDEPLETION)||
                                            ' NOTRANSLATIONENTRYDROPS => '  ||TO_CHAR(T_CGN_STATS_IBHW_TAB(L_IDX).NOTRANSLATIONENTRYDROPS)||
                                            ' ADDRESSTOTALLYFREE => '       ||TO_CHAR(T_CGN_STATS_IBHW_TAB(L_IDX).ADDRESSTOTALLYFREE)||
                                            ' ADDRESSUSED => '              ||TO_CHAR(T_CGN_STATS_IBHW_TAB(L_IDX).ADDRESSUSED)||
                                            ' NUMBEROFSUBSCRIBERS => '      ||TO_CHAR(T_CGN_STATS_IBHW_TAB(L_IDX).NUMBEROFSUBSCRIBERS));
      
            END LOOP;
      END;
      EXIT WHEN cur%NOTFOUND;
    END LOOP;
    COMMIT;
    CLOSE cur;
    --
    EXCEPTION
      WHEN others THEN
        G_ERROR_LOG_NEW.P_LOG_ERROR('P_CGN_STATS_IBHW_INS',
                                    SQLCODE,
                                    SQLERRM,
                                    'P_FECHA_DESDE '||P_fecha_desde||' P_FECHA_HASTA => '||p_fecha_hasta);
  END P_CGN_STATS_IBHW_INS;
  --**--**--
  PROCEDURE P_CALC_SUM_CGN_STATS(P_FECHA IN VARCHAR2) AS
    v_dia VARCHAR2(10 CHAR) := '';
    V_FECHA VARCHAR2(10 CHAR) := '';
  BEGIN
    
    SELECT  to_char(sysdate-1,'DD.MM.YYYY')
    INTO  V_FECHA
    FROM  DUAL;
    
    --
    G_ERROR_LOG_NEW.P_LOG_ERROR('P_CGN_STATS_DAY_INS',0,'NO ERROR','COMIENZO DE SUMARIZACION DAY P_CGN_STATS_DAY_INS('||V_FECHA||')');
    P_CGN_STATS_DAY_INS(V_FECHA,V_FECHA);
    G_ERROR_LOG_NEW.P_LOG_ERROR('P_CGN_STATS_DAY_INS',0,'NO ERROR','FIN DE SUMARIZACION DAY');
    --
    G_ERROR_LOG_NEW.P_LOG_ERROR('P_CGN_STATS_BH_INS',0,'NO ERROR','COMIENZO CALCULO BH P_CGN_STATS_BH_INS('||V_FECHA||')');
    P_CGN_STATS_BH_INS(V_FECHA,V_FECHA);
    G_ERROR_LOG_NEW.P_LOG_ERROR('P_CGN_STATS_BH_INS',0,'NO ERROR','FIN CALCULO BH');
    --
    -- Si el dia actual es DOMINGO, entonces calcular sumarizacion IBHW de la semana anterior,
    -- siempre de domingo a sabado
    --
    SELECT TO_CHAR(TO_DATE(V_FECHA,'DD.MM.YYYY'),'DAY')
    INTO V_DIA
    FROM DUAL;
    
    IF (TRIM(V_DIA) = 'SUNDAY') OR (TRIM(V_DIA) = 'DOMINGO') THEN
      G_ERROR_LOG_NEW.P_LOG_ERROR('P_CGN_STATS_IBHW_INS',0,'NO ERROR','COMIENZO DE SUMARIZACION IBHW P_FECHA_DOMINGO => '||
                                  to_char(to_date(V_FECHA,'DD.MM.YYYY')-7,'DD.MM.YYYY')||
                                  ' P_FECHA_SABADO => '||TO_CHAR(TO_DATE(V_FECHA,'DD.MM.YYYY')-1,'DD.MM.YYYY'));
      --
      P_CGN_STATS_IBHW_INS(to_char(to_date(V_FECHA,'DD.MM.YYYY')-7,'DD.MM.YYYY'),TO_CHAR(TO_DATE(V_FECHA,'DD.MM.YYYY')-1,'DD.MM.YYYY'));
      --
      G_ERROR_LOG_NEW.P_LOG_ERROR('P_CGN_STATS_IBHW_INS',0,'NO ERROR','FIN DE SUMARIZACION IBHW');
    END IF;
  END P_CALC_SUM_CGN_STATS;
  --******************************************************--
  --                CSCO_CPU_MEM_DEVICE_AVG               --
  --******************************************************--
  PROCEDURE P_CSCO_CPU_MEM_DEVICE_AVG_DAY(P_FECHA_DESDE IN VARCHAR2,P_FECHA_HASTA IN VARCHAR2) AS
    --
    TYPE t_cpu_mem_dev_avg_tab IS TABLE OF CSCO_CPU_MEM_DEVICE_AVG_DAY%ROWTYPE;
    v_cpu_mem_dev_avg_tab t_cpu_mem_dev_avg_tab;
    --
    l_errors NUMBER;
    l_errno  NUMBER;
    l_msg    VARCHAR2(4000 CHAR);
    l_idx    NUMBER;
    --
    CURSOR cur (FECHA_DESDE VARCHAR2,FECHA_HASTA VARCHAR2) IS
    select  TRUNC(FECHA)                          FECHA,
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
    WHERE TRUNC(FECHA)  BETWEEN TO_DATE(FECHA_DESDE, 'DD.MM.YYYY')
                           AND TO_DATE(Fecha_Hasta, 'DD.MM.YYYY') + 86399/86400
    GROUP BY TRUNC(FECHA),NODE;
    --
  BEGIN
    OPEN cur(P_FECHA_DESDE,P_FECHA_HASTA);
    LOOP
      FETCH cur BULK COLLECT INTO v_cpu_mem_dev_avg_tab LIMIT limit_in;
      BEGIN
        FORALL indice IN INDICES OF v_cpu_mem_dev_avg_tab
          INSERT INTO CSCO_CPU_MEM_DEVICE_AVG_DAY
          VALUES v_cpu_mem_dev_avg_tab(indice);
        
        EXCEPTION
          WHEN OTHERS THEN
            L_ERRORS := SQL%BULK_EXCEPTIONS.COUNT;
            FOR indice IN 1 .. L_ERRORS
            LOOP
              L_ERRNO := SQL%BULK_EXCEPTIONS(indice).ERROR_CODE;
              L_MSG   := SQLERRM(-L_ERRNO);
              L_IDX   := SQL%BULK_EXCEPTIONS(indice).ERROR_INDEX;
              --
              g_error_log_new.P_LOG_ERROR('P_CSCO_CPU_MEM_DEVICE_AVG_DAY',
                                          L_ERRNO,
                                          L_MSG,
                                          'FECHA => '                     ||v_cpu_mem_dev_avg_tab(L_IDX).FECHA||
                                          ' NODE => '                     ||v_cpu_mem_dev_avg_tab(L_IDX).NODE||
                                          ' CPUUTILMAX5MINDEVICEAVG => '  ||to_char(v_cpu_mem_dev_avg_tab(L_IDX).CPUUTILMAX5MINDEVICEAVG)||
                                          ' CPUUTILAVG5MINDEVICEAVG => '  ||to_char(v_cpu_mem_dev_avg_tab(L_IDX).CPUUTILAVG5MINDEVICEAVG)||
                                          ' CPUUTILMAX1MINDEVICEAVG => '  ||to_char(v_cpu_mem_dev_avg_tab(L_IDX).CPUUTILMAX1MINDEVICEAVG)||
                                          ' CPUUTILAVG1MINDEVICEAVG => '  ||to_char(v_cpu_mem_dev_avg_tab(L_IDX).CPUUTILAVG1MINDEVICEAVG)||
                                          ' USEDBYTESDEVICEAVG => '       ||to_char(v_cpu_mem_dev_avg_tab(L_IDX).USEDBYTESDEVICEAVG)||
                                          ' FREEBYTESDEVICEAVG => '       ||to_char(v_cpu_mem_dev_avg_tab(L_IDX).FREEBYTESDEVICEAVG)||
                                          ' AVGUTILDEVICEAVG => '         ||to_char(v_cpu_mem_dev_avg_tab(L_IDX).AVGUTILDEVICEAVG)||
                                          ' MAXUTILDEVICEAVG => '         ||to_char(v_cpu_mem_dev_avg_tab(L_IDX).MAXUTILDEVICEAVG));
            END LOOP;
      END;
      EXIT WHEN cur%NOTFOUND;
    END LOOP;
    COMMIT;
    CLOSE cur;
    
    EXCEPTION
      WHEN OTHERS THEN
        g_error_log_new.P_LOG_ERROR('P_CSCO_CPU_MEM_DEVICE_AVG_DAY',
                                    SQLCODE,
                                    SQLERRM,
                                    'Fallo al insertar los datos');
  END P_CSCO_CPU_MEM_DEVICE_AVG_DAY;
  --**--**--**--
  PROCEDURE P_CSCO_CPU_MEM_DEVICE_AVG_IBHW(P_FECHA_DESDE IN VARCHAR2,P_FECHA_HASTA IN VARCHAR2) AS
    --
    CURSOR cur(FECHA_DESDE VARCHAR2, FECHA_HASTA VARCHAR2) IS
    WITH  OBJETOS_EHEALTH AS  (SELECT /*+ MATERIALIZE */
                                      ELEMENT_NAME
                              FROM  EHEALTH_OBJECTS_AUX
                              WHERE FLAG_ENABLED = 'S'
                              AND GRUPO != 'IPRAN')
    SELECT  FECHA_DESDE                             FECHA
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
                  ,ROW_NUMBER() OVER (PARTITION BY  TRUNC(FECHA,'DAY'),
                                                    NODE
                                        ORDER BY  CPUUTILMAX5MINDEVICEAVG
                                                  ,TRUNC(FECHA,'DAY') DESC NULLS LAST) SEQNUM
          FROM  CSCO_CPU_MEM_DEVICE_AVG_BH CCMDABH,
                OBJETOS_EHEALTH OE
          WHERE CCMDABH.NODE = OE.ELEMENT_NAME
          )
    WHERE SEQNUM <= LIMIT_PROM
    AND TRUNC(FECHA) BETWEEN TO_DATE(FECHA_DESDE, 'DD.MM.YYYY')
                           AND TO_DATE(FECHA_HASTA, 'DD.MM.YYYY') + 86399/86400
    GROUP BY FECHA,NODE;
    --
    l_errors number;
    l_errno  number;
    l_msg    varchar2(4000);
    l_idx    number;
    --
    TYPE t_csco_cpu_mem_device_avg_ibhw IS TABLE OF CSCO_CPU_MEM_DEVICE_AVG_IBHW%rowtype;
    v_csco_cpu_mem_device_avg_ibhw t_csco_cpu_mem_device_avg_ibhw;
    --
    BEGIN
      EXECUTE IMMEDIATE 'alter session set nls_date_format = ''DD.MM.YYYY HH24:MI:SS''';
      OPEN cur(p_fecha_desde,p_fecha_hasta);
      LOOP
        FETCH cur bulk collect into v_csco_cpu_mem_device_avg_ibhw limit limit_in;
        BEGIN
          FORALL indice IN 1 .. v_csco_cpu_mem_device_avg_ibhw.COUNT SAVE EXCEPTIONS
            INSERT INTO CSCO_CPU_MEM_DEVICE_AVG_IBHW values v_csco_cpu_mem_device_avg_ibhw(indice);
          EXCEPTION
            WHEN OTHERS THEN
              L_ERRORS := SQL%BULK_EXCEPTIONS.COUNT;
              FOR indice IN 1 .. L_ERRORS
              LOOP
                  L_ERRNO := SQL%BULK_EXCEPTIONS(indice).ERROR_CODE;
                  L_MSG   := SQLERRM(-L_ERRNO);
                  L_IDX   := SQL%BULK_EXCEPTIONS(indice).ERROR_INDEX;
                  
                  G_ERROR_LOG_NEW.P_LOG_ERROR('P_CSCO_CPU_MEM_DEVICE_AVG_IBHW',
                                              l_errno,
                                              l_msg,
                                              'FECHA => '                     ||v_csco_cpu_mem_device_avg_ibhw(L_IDX).FECHA||
                                              ' NODE => '                     ||v_csco_cpu_mem_device_avg_ibhw(L_IDX).NODE||
                                              ' CPUUTILMAX5MINDEVICEAVG => '  ||TO_CHAR(v_csco_cpu_mem_device_avg_ibhw(L_IDX).CPUUTILMAX5MINDEVICEAVG)||
                                              ' CPUUTILAVG5MINDEVICEAVG => '  ||TO_CHAR(v_csco_cpu_mem_device_avg_ibhw(L_IDX).CPUUTILAVG5MINDEVICEAVG)||
                                              ' CPUUTILMAX1MINDEVICEAVG => '  ||TO_CHAR(v_csco_cpu_mem_device_avg_ibhw(L_IDX).CPUUTILMAX1MINDEVICEAVG)||
                                              ' CPUUTILAVG1MINDEVICEAVG => '  ||TO_CHAR(v_csco_cpu_mem_device_avg_ibhw(L_IDX).CPUUTILAVG1MINDEVICEAVG)||
                                              ' USEDBYTESDEVICEAVG => '       ||TO_CHAR(v_csco_cpu_mem_device_avg_ibhw(L_IDX).USEDBYTESDEVICEAVG)||
                                              ' FREEBYTESDEVICEAVG => '       ||TO_CHAR(v_csco_cpu_mem_device_avg_ibhw(L_IDX).FREEBYTESDEVICEAVG)||
                                              ' AVGUTILDEVICEAVG => '         ||TO_CHAR(v_csco_cpu_mem_device_avg_ibhw(L_IDX).AVGUTILDEVICEAVG)||
                                              ' MAXUTILDEVICEAVG => '         ||TO_CHAR(v_csco_cpu_mem_device_avg_ibhw(L_IDX).MAXUTILDEVICEAVG));
              END LOOP;
        END;
        EXIT WHEN cur%NOTFOUND;
      END LOOP;
      COMMIT;
      CLOSE cur;
      --
      EXCEPTION
        WHEN others THEN
          G_ERROR_LOG_NEW.P_LOG_ERROR('P_CSCO_CPU_MEM_DEVICE_AVG_IBHW',
                                      SQLCODE,
                                      SQLERRM,
                                      'P_FECHA_DESDE '||P_fecha_desde||' P_FECHA_HASTA => '||p_fecha_hasta);
  END P_CSCO_CPU_MEM_DEVICE_AVG_IBHW;
  --**--**--**--
  PROCEDURE P_CSCO_CPU_MEM_DEVICE_AVG_BH(P_FECHA_DESDE IN VARCHAR2,P_FECHA_HASTA IN VARCHAR2) AS
    --
    CURSOR cur(FECHA_DESDE VARCHAR2,FECHA_HASTA VARCHAR2) IS
    SELECT  FECHA
            ,NODE
            ,CPUUTILMAX5MINDEVICEAVG
            ,CPUUTILAVG5MINDEVICEAVG
            ,CPUUTILMAX1MINDEVICEAVG
            ,CPUUTILAVG1MINDEVICEAVG
            ,USEDBYTESDEVICEAVG
            ,FREEBYTESDEVICEAVG
            ,AVGUTILDEVICEAVG
            ,MAXUTILDEVICEAVG
    FROM  (SELECT TO_CHAR(FECHA,'DD.MM.YYYY HH24') FECHA
                  ,NODE
                  ,CPUUTILMAX5MINDEVICEAVG
                  ,CPUUTILAVG5MINDEVICEAVG
                  ,CPUUTILMAX1MINDEVICEAVG
                  ,CPUUTILAVG1MINDEVICEAVG
                  ,USEDBYTESDEVICEAVG
                  ,FREEBYTESDEVICEAVG
                  ,AVGUTILDEVICEAVG
                  ,MAXUTILDEVICEAVG
                  ,ROW_NUMBER() OVER (PARTITION BY TRUNC(fecha),
                                                   node
                                          ORDER BY (CPUUTILMAX5MINDEVICEAVG) DESC,
                                                   trunc(fecha) DESC NULLS LAST) SEQNUM
          FROM  CSCO_CPU_MEM_DEVICE_AVG_HOUR
          WHERE TRUNC(FECHA) BETWEEN TO_DATE(FECHA_DESDE, 'DD.MM.YYYY')
                               AND TO_DATE(FECHA_HASTA, 'DD.MM.YYYY') + 86399/86400)
    WHERE SEQNUM = 1;
    --
    TYPE t_cpu_mem_device_avg_bh IS TABLE OF CSCO_CPU_MEM_DEVICE_AVG_BH%rowtype;
    v_cpu_mem_device_avg_bh t_cpu_mem_device_avg_bh;
    --
    l_errors NUMBER;
    l_errno  NUMBER;
    l_msg    VARCHAR2(4000 CHAR);
    l_idx    NUMBER;
  BEGIN
    EXECUTE IMMEDIATE 'alter session set nls_date_format = ''DD.MM.YYYY HH24:MI:SS''';
    OPEN cur(P_FECHA_DESDE,P_FECHA_HASTA);
    LOOP
      FETCH cur BULK COLLECT INTO v_cpu_mem_device_avg_bh LIMIT limit_in;
      BEGIN
        FORALL indice IN INDICES OF v_cpu_mem_device_avg_bh
          INSERT INTO CSCO_CPU_MEM_DEVICE_AVG_BH values v_cpu_mem_device_avg_bh(indice);
        
        EXCEPTION
          WHEN OTHERS THEN
            L_ERRORS := SQL%BULK_EXCEPTIONS.COUNT;
            FOR indice IN 1 .. L_ERRORS
            LOOP
              L_ERRNO := SQL%BULK_EXCEPTIONS(indice).ERROR_CODE;
              L_MSG   := SQLERRM(-L_ERRNO);
              L_IDX   := SQL%BULK_EXCEPTIONS(indice).ERROR_INDEX;
              --
              g_error_log_new.P_LOG_ERROR('P_CSCO_CPU_MEM_DEVICE_AVG_BH',
                                          L_ERRNO,
                                          L_MSG,
                                          'FECHA => '                     ||v_cpu_mem_device_avg_bh(L_IDX).FECHA||
                                          ' NODE => '                     ||v_cpu_mem_device_avg_bh(L_IDX).NODE||
                                          ' CPUUTILMAX5MINDEVICEAVG => '  ||TO_CHAR(v_cpu_mem_device_avg_bh(L_IDX).CPUUTILMAX5MINDEVICEAVG)||
                                          ' CPUUTILAVG5MINDEVICEAVG => '  ||TO_CHAR(v_cpu_mem_device_avg_bh(L_IDX).CPUUTILAVG5MINDEVICEAVG)||
                                          ' CPUUTILMAX1MINDEVICEAVG => '  ||TO_CHAR(v_cpu_mem_device_avg_bh(L_IDX).CPUUTILMAX1MINDEVICEAVG)||
                                          ' CPUUTILAVG1MINDEVICEAVG => '  ||TO_CHAR(v_cpu_mem_device_avg_bh(L_IDX).CPUUTILAVG1MINDEVICEAVG)||
                                          ' USEDBYTESDEVICEAVG => '       ||TO_CHAR(v_cpu_mem_device_avg_bh(L_IDX).USEDBYTESDEVICEAVG)||
                                          ' FREEBYTESDEVICEAVG => '       ||TO_CHAR(v_cpu_mem_device_avg_bh(L_IDX).FREEBYTESDEVICEAVG)||
                                          ' AVGUTILDEVICEAVG => '         ||TO_CHAR(v_cpu_mem_device_avg_bh(L_IDX).AVGUTILDEVICEAVG)||
                                          ' MAXUTILDEVICEAVG => '         ||TO_CHAR(v_cpu_mem_device_avg_bh(L_IDX).MAXUTILDEVICEAVG));
            END LOOP;
      END;
      EXIT WHEN cur%NOTFOUND;
    END LOOP;
    COMMIT;
    CLOSE cur;
    
    EXCEPTION
      WHEN OTHERS THEN
        g_error_log_new.P_LOG_ERROR('P_CSCO_CPU_MEM_DEVICE_AVG_BH',
                                    SQLCODE,
                                    SQLERRM,
                                    'Fallo al insertar los datos');
  END P_CSCO_CPU_MEM_DEVICE_AVG_BH;
  --**--**--**--
  PROCEDURE P_CALC_SUM_CPU_MEM_DEVICE_AVG(P_FECHA IN VARCHAR2) AS
    v_dia VARCHAR2(10 CHAR) := '';
    V_FECHA VARCHAR2(10 CHAR) := '';
  BEGIN
    
    SELECT  to_char(sysdate-1,'DD.MM.YYYY')
    INTO  V_FECHA
    FROM  DUAL;
    --
    G_ERROR_LOG_NEW.P_LOG_ERROR('P_CSCO_CPU_MEM_DEVICE_AVG_DAY',0,'NO ERROR','COMIENZO DE SUMARIZACION DAY P_CSCO_CPU_MEM_DEVICE_AVG_DAY('||V_FECHA||')');
    P_CSCO_CPU_MEM_DEVICE_AVG_DAY(V_FECHA,V_FECHA);
    G_ERROR_LOG_NEW.P_LOG_ERROR('P_CSCO_CPU_MEM_DEVICE_AVG_DAY',0,'NO ERROR','FIN DE SUMARIZACION DAY');
    --
    G_ERROR_LOG_NEW.P_LOG_ERROR('P_CSCO_CPU_MEM_DEVICE_AVG_BH',0,'NO ERROR','COMIENZO CALCULO BH P_CSCO_CPU_MEM_DEVICE_AVG_BH('||V_FECHA||')');
    P_CSCO_CPU_MEM_DEVICE_AVG_BH(V_FECHA,V_FECHA);
    G_ERROR_LOG_NEW.P_LOG_ERROR('P_CSCO_CPU_MEM_DEVICE_AVG_BH',0,'NO ERROR','FIN CALCULO BH');
    --
    -- Si el dia actual es DOMINGO, entonces calcular sumarizacion IBHW de la semana anterior,
    -- siempre de domingo a sabado
    --
    SELECT TO_CHAR(TO_DATE(V_FECHA,'DD.MM.YYYY'),'DAY')
    INTO V_DIA
    FROM DUAL;
    
    IF (TRIM(V_DIA) = 'SUNDAY') OR (TRIM(V_DIA) = 'DOMINGO') THEN
      G_ERROR_LOG_NEW.P_LOG_ERROR('P_CSCO_CPU_MEM_DEVICE_AVG_IBHW',0,'NO ERROR','COMIENZO DE SUMARIZACION IBHW P_FECHA_DOMINGO => '||
                                  to_char(to_date(V_FECHA,'DD.MM.YYYY')-7,'DD.MM.YYYY')||
                                  ' P_FECHA_SABADO => '||TO_CHAR(TO_DATE(V_FECHA,'DD.MM.YYYY')-1,'DD.MM.YYYY'));
      --
      P_CSCO_CPU_MEM_DEVICE_AVG_IBHW(to_char(to_date(V_FECHA,'DD.MM.YYYY')-7,'DD.MM.YYYY'),TO_CHAR(TO_DATE(V_FECHA,'DD.MM.YYYY')-1,'DD.MM.YYYY'));
      --
      G_ERROR_LOG_NEW.P_LOG_ERROR('P_CSCO_CPU_MEM_DEVICE_AVG_IBHW',0,'NO ERROR','FIN DE SUMARIZACION IBHW');
    END IF;
  END P_CALC_SUM_CPU_MEM_DEVICE_AVG;
  --******************************************************--
  --                 EHEALTH_STAT_IP                      --
  --******************************************************--
  PROCEDURE P_EHEALTH_STAT_IP_BH(P_FECHA_DESDE IN VARCHAR2,P_FECHA_HASTA IN VARCHAR2) AS
  --
    TYPE t_element_id_fecha IS TABLE OF VARCHAR2(255 CHAR);
    v_element_id_fecha t_element_id_fecha;
    --
    CURSOR cur(FECHA_DESDE VARCHAR2,FECHA_HASTA VARCHAR2) IS
    WITH  OBJETOS_EHEALTH AS  (SELECT /*+ MATERIALIZE */
                                      ELEMENT_ID
                              FROM  EHEALTH_OBJECTS_AUX
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
                                        WHERE FECHA BETWEEN TO_DATE(FECHA_DESDE,'DD.MM.YYYY')
                                                AND TO_DATE(FECHA_HASTA, 'DD.MM.YYYY') + 86399/86400
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
                                          WHERE FECHA BETWEEN TO_DATE(FECHA_DESDE,'DD.MM.YYYY')
                                                AND TO_DATE(FECHA_HASTA, 'DD.MM.YYYY') + 86399/86400
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
    l_errors NUMBER;
    l_errno  NUMBER;
    l_msg    VARCHAR2(4000 CHAR);
    l_idx    NUMBER;
  BEGIN
    OPEN cur(P_FECHA_DESDE,P_FECHA_HASTA);
    LOOP
      FETCH cur BULK COLLECT INTO v_element_id_fecha LIMIT limit_in;
      BEGIN
        FORALL indice IN INDICES OF v_element_id_fecha
          INSERT INTO EHEALTH_STAT_IP_BH (FECHA,ELEMENT_ID,RECEIVEBYTES,SENDBYTES,IFSPEED,RECEIVEDISCARDS,SENDDISCARDS,
                                        RECEIVEERRORS,SENDERRORS,RECEIVETOTALPKTRATE,SENDTOTALPKTRATE,INQUEUEDROPS,
                                        OUTQUEUEDROPS,UPPERCENT,SENDUTIL,SENDTOTALPKTS,SENDUCASTPKTPERCENT,
                                        SENDMCASTPKTPERCENT,SENDBCASTPKTPERCENT,SENDERRORPERCENT,SENDDISCARDPERCENT,
                                        RECEIVEUTIL,RECEIVETOTALPKTS,RECEIVEUCASTPKTPERCENT,RECEIVEMCASTPKTPERCENT,
                                        RECEIVEBCASTPKTPERCENT,RECEIVEERRORPERCENT,RECEIVEDISCARDPERCENT,
                                        SENDBCASTPKTRATE,RECEIVEBCASTPKTRATE)
          SELECT  FECHA,ELEMENT_ID,RECEIVEBYTES,SENDBYTES,IFSPEED,RECEIVEDISCARDS,SENDDISCARDS,
                  RECEIVEERRORS,SENDERRORS,RECEIVETOTALPKTRATE,SENDTOTALPKTRATE,INQUEUEDROPS,
                  OUTQUEUEDROPS,UPPERCENT,SENDUTIL,SENDTOTALPKTS,SENDUCASTPKTPERCENT,
                  SENDMCASTPKTPERCENT,SENDBCASTPKTPERCENT,SENDERRORPERCENT,SENDDISCARDPERCENT,
                  RECEIVEUTIL,RECEIVETOTALPKTS,RECEIVEUCASTPKTPERCENT,RECEIVEMCASTPKTPERCENT,
                  RECEIVEBCASTPKTPERCENT,RECEIVEERRORPERCENT,RECEIVEDISCARDPERCENT,
                  SENDBCASTPKTRATE,RECEIVEBCASTPKTRATE
          FROM  EHEALTH_STAT_IP_HOUR ESIH
          WHERE ESIH.ELEMENT_ID   = substr(v_element_id_fecha(indice),1,instr(v_element_id_fecha(indice),',')-1)
          AND   ESIH.FECHA  = substr(v_element_id_fecha(indice),instr(v_element_id_fecha(indice),',')+1,length(v_element_id_fecha(indice)));--FECHA
        
        EXCEPTION
          WHEN OTHERS THEN
            L_ERRORS := SQL%BULK_EXCEPTIONS.COUNT;
            FOR indice IN 1 .. L_ERRORS
            LOOP
              L_ERRNO := SQL%BULK_EXCEPTIONS(indice).ERROR_CODE;
              L_MSG   := SQLERRM(-L_ERRNO);
              L_IDX   := SQL%BULK_EXCEPTIONS(indice).ERROR_INDEX;
              --
              g_error_log_new.P_LOG_ERROR('P_EHEALTH_STAT_IP_BH',
                                          L_ERRNO,
                                          L_MSG,
                                          'FECHA => '||substr(v_element_id_fecha(indice),instr(v_element_id_fecha(indice),',')+1,length(v_element_id_fecha(indice))-1)||
                                          ' NODE => '||substr(v_element_id_fecha(indice),1,instr(v_element_id_fecha(indice),',')));

            END LOOP;
      END;
      EXIT WHEN cur%NOTFOUND;
    END LOOP;
    COMMIT;
    CLOSE cur;
    
    EXCEPTION
      WHEN OTHERS THEN
        g_error_log_new.P_LOG_ERROR('P_EHEALTH_STAT_IP_BH',
                                    SQLCODE,
                                    SQLERRM,
                                    'Fallo al insertar los datos');
  END P_EHEALTH_STAT_IP_BH;
  --**--**--**--
  PROCEDURE P_EHEALTH_STAT_IP_IBHW(P_FECHA_DESDE IN VARCHAR2,P_FECHA_HASTA IN VARCHAR2) AS
    
    TYPE t_ehealth_stat_ip_ibhw IS TABLE OF EHEALTH_STAT_IP_IBHW%rowtype;
    v_ehealth_stat_ip_ibhw t_ehealth_stat_ip_ibhw;
    
    l_errors NUMBER;
    l_errno  NUMBER;
    l_msg    VARCHAR2(4000 CHAR);
    l_idx    NUMBER;
    CURSOR CUR (FECHA_DESDE VARCHAR2, FECHA_HASTA VARCHAR2) IS
    SELECT  FECHA_DESDE                           FECHA
            ,ELEMENT_ID
            ,ROUND(AVG(RECEIVEBYTES),2)           RECEIVEBYTES
            ,ROUND(AVG(SENDBYTES),2)              SENDBYTES
            ,ROUND(AVG(IFSPEED),2)                IFSPEED
            ,ROUND(AVG(RECEIVEDISCARDS),2)        RECEIVEDISCARDS
            ,ROUND(AVG(SENDDISCARDS),2)           SENDDISCARDS
            ,ROUND(AVG(RECEIVEERRORS),2)          RECEIVEERRORS
            ,ROUND(AVG(SENDERRORS),2)             SENDERRORS
            ,ROUND(AVG(RECEIVETOTALPKTRATE),2)    RECEIVETOTALPKTRATE
            ,ROUND(AVG(SENDTOTALPKTRATE),2)       SENDTOTALPKTRATE
            ,ROUND(AVG(INQUEUEDROPS),2)           INQUEUEDROPS
            ,ROUND(AVG(OUTQUEUEDROPS),2)          OUTQUEUEDROPS
            ,ROUND(AVG(UPPERCENT),2)              UPPERCENT
            ,ROUND(AVG(SENDUTIL),2)               SENDUTIL
            ,ROUND(AVG(SENDTOTALPKTS),2)          SENDTOTALPKTS
            ,ROUND(AVG(SENDUCASTPKTPERCENT),2)    SENDUCASTPKTPERCENT
            ,ROUND(AVG(SENDMCASTPKTPERCENT),2)    SENDMCASTPKTPERCENT
            ,ROUND(AVG(SENDBCASTPKTPERCENT),2)    SENDBCASTPKTPERCENT
            ,ROUND(AVG(SENDERRORPERCENT),2)       SENDERRORPERCENT
            ,ROUND(AVG(SENDDISCARDPERCENT),2)     SENDDISCARDPERCENT
            ,ROUND(AVG(RECEIVEUTIL),2)            RECEIVEUTIL
            ,ROUND(AVG(RECEIVETOTALPKTS),2)       RECEIVETOTALPKTS
            ,ROUND(AVG(RECEIVEUCASTPKTPERCENT),2) RECEIVEUCASTPKTPERCENT
            ,ROUND(AVG(RECEIVEMCASTPKTPERCENT),2) RECEIVEMCASTPKTPERCENT
            ,ROUND(AVG(RECEIVEBCASTPKTPERCENT),2) RECEIVEBCASTPKTPERCENT
            ,ROUND(AVG(RECEIVEERRORPERCENT),2)    RECEIVEERRORPERCENT
            ,ROUND(AVG(RECEIVEDISCARDPERCENT),2)  RECEIVEDISCARDPERCENT
            ,ROUND(AVG(SENDBCASTPKTRATE),2)       SENDBCASTPKTRATE
            ,ROUND(AVG(RECEIVEBCASTPKTRATE),2)    RECEIVEBCASTPKTRATE
    FROM  (SELECT  TRUNC(ESIB.FECHA,'DAY') FECHA
                  ,ESIB.ELEMENT_ID ELEMENT_ID
                  ,RECEIVEBYTES
                  ,SENDBYTES
                  ,IFSPEED
                  ,RECEIVEDISCARDS
                  ,SENDDISCARDS
                  ,RECEIVEERRORS
                  ,SENDERRORS
                  ,RECEIVETOTALPKTRATE
                  ,SENDTOTALPKTRATE
                  ,INQUEUEDROPS
                  ,OUTQUEUEDROPS
                  ,UPPERCENT
                  ,SENDUTIL
                  ,SENDTOTALPKTS
                  ,SENDUCASTPKTPERCENT
                  ,SENDMCASTPKTPERCENT
                  ,SENDBCASTPKTPERCENT
                  ,SENDERRORPERCENT
                  ,SENDDISCARDPERCENT
                  ,RECEIVEUTIL
                  ,RECEIVETOTALPKTS
                  ,RECEIVEUCASTPKTPERCENT
                  ,RECEIVEMCASTPKTPERCENT
                  ,RECEIVEBCASTPKTPERCENT
                  ,RECEIVEERRORPERCENT
                  ,RECEIVEDISCARDPERCENT
                  ,SENDBCASTPKTRATE
                  ,RECEIVEBCASTPKTRATE
                  ,ROW_NUMBER() OVER (PARTITION BY ESIB.ELEMENT_ID ORDER BY ORDER_COLUMN.ORDER_BY) RN
          FROM  EHEALTH_STAT_IP_BH ESIB,
                (SELECT ELEMENT_ID,
                       CASE
                        WHEN MAX(SENDBYTES) >= MAX(RECEIVEBYTES) THEN 'SENDBYTES' ELSE 'RECEIVEBYTES'
                       END ORDER_BY
                FROM EHEALTH_STAT_IP_BH
                WHERE TRUNC(FECHA) BETWEEN TO_DATE(FECHA_DESDE,'DD.MM.YYYY')
                                    AND TO_DATE(FECHA_HASTA, 'DD.MM.YYYY') + 86399/86400 --FECHA_DESDE AND FECHA_HASTA
                GROUP BY ELEMENT_ID) ORDER_COLUMN
          WHERE ESIB.ELEMENT_ID = ORDER_COLUMN.ELEMENT_ID
          AND TRUNC(ESIB.FECHA) BETWEEN TO_DATE(FECHA_DESDE,'DD.MM.YYYY')
                                  AND TO_DATE(FECHA_HASTA, 'DD.MM.YYYY') + 86399/86400) --FECHA_DESDE AND FECHA_HASTA)
    WHERE RN < = 3
    GROUP BY ELEMENT_ID;
  --
  BEGIN

    OPEN CUR(P_FECHA_DESDE,P_FECHA_HASTA);
    LOOP
      FETCH CUR BULK COLLECT INTO v_ehealth_stat_ip_ibhw LIMIT limit_in;
      BEGIN
        FORALL indice IN 1 .. v_ehealth_stat_ip_ibhw.COUNT SAVE EXCEPTIONS
          INSERT INTO EHEALTH_STAT_IP_IBHW VALUES v_ehealth_stat_ip_ibhw(indice);
        EXCEPTION
          WHEN OTHERS THEN
            L_ERRORS := SQL%BULK_EXCEPTIONS.COUNT;
            FOR indice_e IN 1 .. L_ERRORS
            LOOP
                L_ERRNO := SQL%BULK_EXCEPTIONS(indice_e).ERROR_CODE;
                L_MSG   := SQLERRM(-L_ERRNO);
                L_IDX   := SQL%BULK_EXCEPTIONS(indice_e).ERROR_INDEX;
                
                G_ERROR_LOG_NEW.P_LOG_ERROR('P_EHEALTH_STAT_IP_IBHW',
                                            l_errno,
                                            l_msg,
                                            'FECHA => '                   ||v_ehealth_stat_ip_ibhw(l_idx).FECHA||
                                            ' ELEMENT_ID => '             ||to_char(v_ehealth_stat_ip_ibhw(l_idx).ELEMENT_ID)||
                                            ' RECEIVEBYTES => '           ||to_char(v_ehealth_stat_ip_ibhw(l_idx).RECEIVEBYTES)||
                                            ' SENDBYTES => '              ||to_char(v_ehealth_stat_ip_ibhw(l_idx).SENDBYTES)||
                                            ' IFSPEED => '                ||to_char(v_ehealth_stat_ip_ibhw(l_idx).IFSPEED)||
                                            ' RECEIVEDISCARDS => '        ||to_char(v_ehealth_stat_ip_ibhw(l_idx).RECEIVEDISCARDS)||
                                            ' SENDDISCARDS => '           ||to_char(v_ehealth_stat_ip_ibhw(l_idx).SENDDISCARDS)||
                                            ' RECEIVEERRORS => '          ||to_char(v_ehealth_stat_ip_ibhw(l_idx).RECEIVEERRORS)||
                                            ' SENDERRORS => '             ||to_char(v_ehealth_stat_ip_ibhw(l_idx).SENDERRORS)||
                                            ' RECEIVETOTALPKTRATE => '    ||to_char(v_ehealth_stat_ip_ibhw(l_idx).RECEIVETOTALPKTRATE)||
                                            ' SENDTOTALPKTRATE => '       ||to_char(v_ehealth_stat_ip_ibhw(l_idx).SENDTOTALPKTRATE)||
                                            ' INQUEUEDROPS => '           ||to_char(v_ehealth_stat_ip_ibhw(l_idx).INQUEUEDROPS)||
                                            ' OUTQUEUEDROPS => '          ||to_char(v_ehealth_stat_ip_ibhw(l_idx).OUTQUEUEDROPS)||
                                            ' UPPERCENT => '              ||to_char(v_ehealth_stat_ip_ibhw(l_idx).UPPERCENT)||
                                            ' SENDUTIL => '               ||to_char(v_ehealth_stat_ip_ibhw(l_idx).SENDUTIL)||
                                            ' SENDTOTALPKTS => '          ||to_char(v_ehealth_stat_ip_ibhw(l_idx).SENDTOTALPKTS)||
                                            ' SENDUCASTPKTPERCENT => '    ||to_char(v_ehealth_stat_ip_ibhw(l_idx).SENDUCASTPKTPERCENT)||
                                            ' SENDMCASTPKTPERCENT => '    ||to_char(v_ehealth_stat_ip_ibhw(l_idx).SENDMCASTPKTPERCENT)||
                                            ' SENDBCASTPKTPERCENT => '    ||to_char(v_ehealth_stat_ip_ibhw(l_idx).SENDBCASTPKTPERCENT)||
                                            ' SENDERRORPERCENT => '       ||to_char(v_ehealth_stat_ip_ibhw(l_idx).SENDERRORPERCENT)||
                                            ' SENDDISCARDPERCENT => '     ||to_char(v_ehealth_stat_ip_ibhw(l_idx).SENDDISCARDPERCENT)||
                                            ' RECEIVEUTIL => '            ||to_char(v_ehealth_stat_ip_ibhw(l_idx).RECEIVEUTIL)||
                                            ' RECEIVETOTALPKTS => '       ||to_char(v_ehealth_stat_ip_ibhw(l_idx).RECEIVETOTALPKTS)||
                                            ' RECEIVEUCASTPKTPERCENT => ' ||to_char(v_ehealth_stat_ip_ibhw(l_idx).RECEIVEUCASTPKTPERCENT)||
                                            ' RECEIVEMCASTPKTPERCENT => ' ||to_char(v_ehealth_stat_ip_ibhw(l_idx).RECEIVEMCASTPKTPERCENT)||
                                            ' RECEIVEBCASTPKTPERCENT => ' ||to_char(v_ehealth_stat_ip_ibhw(l_idx).RECEIVEBCASTPKTPERCENT)||
                                            ' RECEIVEERRORPERCENT => '    ||to_char(v_ehealth_stat_ip_ibhw(l_idx).RECEIVEERRORPERCENT)||
                                            ' RECEIVEDISCARDPERCENT => '  ||to_char(v_ehealth_stat_ip_ibhw(l_idx).RECEIVEDISCARDPERCENT)||
                                            ' SENDBCASTPKTRATE => '       ||to_char(v_ehealth_stat_ip_ibhw(l_idx).SENDBCASTPKTRATE)||
                                            ' RECEIVEBCASTPKTRATE => '    ||to_char(v_ehealth_stat_ip_ibhw(l_idx).RECEIVEBCASTPKTRATE));
            END LOOP;
      END;
      exit when CUR%notfound;
    END loop;
    COMMIT;
    CLOSE CUR;
    EXCEPTION
      WHEN OTHERS THEN
        G_ERROR_LOG_NEW.P_LOG_ERROR('P_EHEALTH_STAT_IP_IBHW',
                                    SQLCODE,
                                    SQLERRM,
                                    'P_FECHA_DESDE '||P_FECHA_DESDE||' P_FECHA_HASTA => '||P_FECHA_HASTA);
  END P_EHEALTH_STAT_IP_IBHW;
  --**--**--**--
  PROCEDURE P_EHEALTH_STAT_IP_DAY(P_FECHA_DESDE IN VARCHAR2,P_FECHA_HASTA IN VARCHAR2) AS
  --
    TYPE t_ehealth_stat_ip_day IS TABLE OF EHEALTH_STAT_IP_DAY%rowtype;
    v_ehealth_stat_ip_day t_ehealth_stat_ip_day;
    
    l_errors NUMBER;
    l_errno  NUMBER;
    l_msg    VARCHAR2(4000 CHAR);
    l_idx    NUMBER;
    CURSOR cur (fecha_desde VARCHAR2, fecha_hasta VARCHAR2) IS
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
    WHERE FECHA BETWEEN TO_DATE(fecha_desde ,'DD.MM.YYYY')
                     AND TO_DATE(fecha_hasta,'DD.MM.YYYY') + 86399/86400
    GROUP BY TRUNC(FECHA),ELEMENT_ID;
  --
  BEGIN

    OPEN cur(p_fecha_desde,p_fecha_hasta);
    LOOP
      FETCH cur BULK COLLECT INTO v_ehealth_stat_ip_day LIMIT limit_in;
      BEGIN
        FORALL indice IN 1 .. v_ehealth_stat_ip_day.COUNT SAVE EXCEPTIONS
          INSERT INTO EHEALTH_STAT_IP_DAY VALUES v_ehealth_stat_ip_day(indice);
        EXCEPTION
          WHEN OTHERS THEN
            L_ERRORS := SQL%BULK_EXCEPTIONS.COUNT;
            FOR indice_e IN 1 .. L_ERRORS
            LOOP
                L_ERRNO := SQL%BULK_EXCEPTIONS(indice_e).ERROR_CODE;
                L_MSG   := SQLERRM(-L_ERRNO);
                L_IDX   := SQL%BULK_EXCEPTIONS(indice_e).ERROR_INDEX;
                
                G_ERROR_LOG_NEW.P_LOG_ERROR('P_EHEALTH_STAT_IP_DAY',
                                            l_errno,
                                            l_msg,
                                            'FECHA => '||v_ehealth_stat_ip_day(l_idx).FECHA||
                                            ' ELEMENT_ID => '||v_ehealth_stat_ip_day(l_idx).ELEMENT_ID||
                                            ' RECEIVEBYTES => '||v_ehealth_stat_ip_day(l_idx).RECEIVEBYTES||
                                            ' SENDBYTES => '||to_char(v_ehealth_stat_ip_day(l_idx).SENDBYTES)||
                                            ' IFSPEED => '||to_char(v_ehealth_stat_ip_day(l_idx).IFSPEED)||
                                            ' RECEIVEDISCARDS => '||to_char(v_ehealth_stat_ip_day(l_idx).RECEIVEDISCARDS)||
                                            ' SENDDISCARDS => '||to_char(v_ehealth_stat_ip_day(l_idx).SENDDISCARDS)||
                                            ' RECEIVEERRORS => '||to_char(v_ehealth_stat_ip_day(l_idx).RECEIVEERRORS)||
                                            ' SENDERRORS => '||to_char(v_ehealth_stat_ip_day(l_idx).SENDERRORS)||
                                            ' RECEIVETOTALPKTRATE => '||to_char(v_ehealth_stat_ip_day(l_idx).RECEIVETOTALPKTRATE)||
                                            ' SENDTOTALPKTRATE => '||to_char(v_ehealth_stat_ip_day(l_idx).SENDTOTALPKTRATE)||
                                            ' INQUEUEDROPS => '||to_char(v_ehealth_stat_ip_day(l_idx).INQUEUEDROPS)||
                                            ' OUTQUEUEDROPS => '||to_char(v_ehealth_stat_ip_day(l_idx).OUTQUEUEDROPS)||
                                            ' UPPERCENT => '||to_char(v_ehealth_stat_ip_day(l_idx).UPPERCENT)||
                                            ' SENDUTIL => '||to_char(v_ehealth_stat_ip_day(l_idx).SENDUTIL)||
                                            ' SENDTOTALPKTS => '||to_char(v_ehealth_stat_ip_day(l_idx).SENDTOTALPKTS)||
                                            ' SENDUCASTPKTPERCENT => '||to_char(v_ehealth_stat_ip_day(l_idx).SENDUCASTPKTPERCENT)||
                                            ' SENDMCASTPKTPERCENT => '||to_char(v_ehealth_stat_ip_day(l_idx).SENDMCASTPKTPERCENT)||
                                            ' SENDBCASTPKTPERCENT => '||to_char(v_ehealth_stat_ip_day(l_idx).SENDBCASTPKTPERCENT)||
                                            ' SENDERRORPERCENT => '||to_char(v_ehealth_stat_ip_day(l_idx).SENDERRORPERCENT)||
                                            ' SENDDISCARDPERCENT => '||to_char(v_ehealth_stat_ip_day(l_idx).SENDDISCARDPERCENT)||
                                            ' RECEIVEUTIL => '||to_char(v_ehealth_stat_ip_day(l_idx).RECEIVEUTIL)||
                                            ' RECEIVETOTALPKTS => '||to_char(v_ehealth_stat_ip_day(l_idx).RECEIVETOTALPKTS)||
                                            ' RECEIVEUCASTPKTPERCENT => '||to_char(v_ehealth_stat_ip_day(l_idx).RECEIVEUCASTPKTPERCENT)||
                                            ' RECEIVEMCASTPKTPERCENT => '||to_char(v_ehealth_stat_ip_day(l_idx).RECEIVEMCASTPKTPERCENT)||
                                            ' RECEIVEBCASTPKTPERCENT => '||to_char(v_ehealth_stat_ip_day(l_idx).RECEIVEBCASTPKTPERCENT)||
                                            ' RECEIVEERRORPERCENT => '||to_char(v_ehealth_stat_ip_day(l_idx).RECEIVEERRORPERCENT)||
                                            ' RECEIVEDISCARDPERCENT => '||to_char(v_ehealth_stat_ip_day(l_idx).RECEIVEDISCARDPERCENT)||
                                            ' SENDBCASTPKTRATE => '||to_char(v_ehealth_stat_ip_day(l_idx).SENDBCASTPKTRATE)||
                                            ' RECEIVEBCASTPKTRATE => '||to_char(v_ehealth_stat_ip_day(l_idx).RECEIVEBCASTPKTRATE));
            END LOOP;
      END;
      exit when cur%notfound;
    END loop;
    COMMIT;
    CLOSE cur;
    EXCEPTION
      WHEN OTHERS THEN
        G_ERROR_LOG_NEW.P_LOG_ERROR('P_EHEALTH_STAT_IP_DAY',
                                    SQLCODE,
                                    SQLERRM,
                                    'P_FECHA_DESDE '||P_fecha_desde||' P_FECHA_HASTA => '||p_fecha_hasta);
  END P_EHEALTH_STAT_IP_DAY;
  --**--**--**--
  PROCEDURE P_CALC_SUM_EHEALTH_STAT_IP(P_FECHA IN VARCHAR2) AS
    v_dia VARCHAR2(10 CHAR) := '';
    V_FECHA VARCHAR2(10 CHAR) := '';
  BEGIN
    
    SELECT  to_char(sysdate-1,'DD.MM.YYYY')
    INTO  V_FECHA
    FROM  DUAL;
    --
    G_ERROR_LOG_NEW.P_LOG_ERROR('P_EHEALTH_STAT_IP_DAY',0,'NO ERROR','COMIENZO DE SUMARIZACION DAY P_EHEALTH_STAT_IP_DAY('||V_FECHA||')');
    P_EHEALTH_STAT_IP_DAY(V_FECHA,V_FECHA);
    G_ERROR_LOG_NEW.P_LOG_ERROR('P_EHEALTH_STAT_IP_DAY',0,'NO ERROR','FIN DE SUMARIZACION DAY');
    --
    G_ERROR_LOG_NEW.P_LOG_ERROR('P_EHEALTH_STAT_IP_BH',0,'NO ERROR','COMIENZO CALCULO BH P_CSCO_CPU_MEM_DEVICE_AVG_BH('||V_FECHA||')');
    P_EHEALTH_STAT_IP_BH(V_FECHA,V_FECHA);
    G_ERROR_LOG_NEW.P_LOG_ERROR('P_EHEALTH_STAT_IP_BH',0,'NO ERROR','FIN CALCULO BH');
    --
    -- Si el dia actual es DOMINGO, entonces calcular sumarizacion IBHW de la semana anterior,
    -- siempre de domingo a sabado
    --
    SELECT TO_CHAR(TO_DATE(V_FECHA,'DD.MM.YYYY'),'DAY')
    INTO V_DIA
    FROM DUAL;
    
    IF (TRIM(V_DIA) = 'SUNDAY') OR (TRIM(V_DIA) = 'DOMINGO') THEN
      G_ERROR_LOG_NEW.P_LOG_ERROR('P_EHEALTH_STAT_IP_IBHW',0,'NO ERROR','COMIENZO DE SUMARIZACION IBHW P_FECHA_DOMINGO => '||
                                  to_char(to_date(V_FECHA,'DD.MM.YYYY')-7,'DD.MM.YYYY')||
                                  ' P_FECHA_SABADO => '||TO_CHAR(TO_DATE(V_FECHA,'DD.MM.YYYY')-1,'DD.MM.YYYY'));
      --
      P_EHEALTH_STAT_IP_IBHW(to_char(to_date(V_FECHA,'DD.MM.YYYY')-7,'DD.MM.YYYY'),TO_CHAR(TO_DATE(V_FECHA,'DD.MM.YYYY')-1,'DD.MM.YYYY'));
      --
      G_ERROR_LOG_NEW.P_LOG_ERROR('P_EHEALTH_STAT_IP_IBHW',0,'NO ERROR','FIN DE SUMARIZACION IBHW');
    END IF;
  END P_CALC_SUM_EHEALTH_STAT_IP;
  
END G_CISCO_PRIME;
/
