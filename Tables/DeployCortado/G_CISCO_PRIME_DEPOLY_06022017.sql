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
--  --******************************************************--
--  --                EHEALTH_STAT_IP                       --
--  --******************************************************--
--  /**
--  *
--  */
--  PROCEDURE P_EHEALTH_STAT_IP_BH(P_FECHA_DESDE IN VARCHAR2,P_FECHA_HASTA IN VARCHAR2);
--  /**
--  *
--  */
--  PROCEDURE P_EHEALTH_STAT_IP_IBHW(P_FECHA_DESDE IN VARCHAR2,P_FECHA_HASTA IN VARCHAR2);
--  /**
--  *
--  */
--  PROCEDURE P_EHEALTH_STAT_IP_DAY(P_FECHA_DESDE IN VARCHAR2,P_FECHA_HASTA IN VARCHAR2);
--  /**
--  *
--  */
--  PROCEDURE P_CALC_SUM_EHEALTH_STAT_IP(P_FECHA IN VARCHAR2);
  --******************************************************--
  --                      INTERFACE                       --
  --******************************************************--
  /**
  *
  */
  PROCEDURE P_CSCO_INTERFACE_DAY(P_FECHA_DESDE IN VARCHAR2,P_FECHA_HASTA IN VARCHAR2);
  /**
  *
  */
  PROCEDURE P_CSCO_INTERFACE_BH(P_FECHA_DESDE IN VARCHAR2,P_FECHA_HASTA IN VARCHAR2);
  /**
  *
  */
  PROCEDURE P_CSCO_INTERFACE_IBHW(P_FECHA_DESDE IN VARCHAR2,P_FECHA_HASTA IN VARCHAR2);
  /**
  *
  */
  PROCEDURE P_CALC_SUM_INTERFACE(P_FECHA IN VARCHAR2);
  /**
  *
  */
  PROCEDURE P_CALC_SUM_INTERFACE_RWK(P_FECHA IN VARCHAR2);
END G_CISCO_PRIME;
/


CREATE OR REPLACE PACKAGE BODY G_CISCO_PRIME AS

  FUNCTION F_RECALCULAR_IBHW(P_DATE IN VARCHAR2) RETURN NUMBER IS
    V_CURRENT_WEEK  NUMBER; -- week
    V_DATE_WEEK     NUMBER; -- week that given date belongs to
  BEGIN
    SELECT  TO_CHAR(TO_DATE(P_DATE, 'DD.MM.YYYY'), 'ww') AS WEEKNUMBER 
    INTO    V_DATE_WEEK
    FROM    DUAL;
    --
    SELECT  TO_CHAR(SYSDATE, 'ww') AS WEEKNUMBER 
    INTO    V_CURRENT_WEEK
    FROM    DUAL;
    --
    IF V_CURRENT_WEEK != V_DATE_WEEK THEN
      RETURN 1;
    END IF;
    --
    RETURN 0;
  END F_RECALCULAR_IBHW;
  --**--**--**--

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
    
--    SELECT  to_char(sysdate-1,'DD.MM.YYYY')
--    INTO  V_FECHA
--    FROM  DUAL;
    
    --
    G_ERROR_LOG_NEW.P_LOG_ERROR('P_CGN_STATS_DAY_INS',0,'NO ERROR','COMIENZO DE SUMARIZACION DAY P_CGN_STATS_DAY_INS('||P_FECHA||')');
    P_CGN_STATS_DAY_INS(P_FECHA,P_FECHA);
    G_ERROR_LOG_NEW.P_LOG_ERROR('P_CGN_STATS_DAY_INS',0,'NO ERROR','FIN DE SUMARIZACION DAY');
    --
    G_ERROR_LOG_NEW.P_LOG_ERROR('P_CGN_STATS_BH_INS',0,'NO ERROR','COMIENZO CALCULO BH P_CGN_STATS_BH_INS('||P_FECHA||')');
    P_CGN_STATS_BH_INS(P_FECHA,P_FECHA);
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
                                  to_char(to_date(P_FECHA,'DD.MM.YYYY')-7,'DD.MM.YYYY')||
                                  ' P_FECHA_SABADO => '||TO_CHAR(TO_DATE(P_FECHA,'DD.MM.YYYY')-1,'DD.MM.YYYY'));
      --
      P_CGN_STATS_IBHW_INS(to_char(to_date(P_FECHA,'DD.MM.YYYY')-7,'DD.MM.YYYY'),TO_CHAR(TO_DATE(P_FECHA,'DD.MM.YYYY')-1,'DD.MM.YYYY'));
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
    EXECUTE IMMEDIATE 'alter session set nls_date_format = ''DD.MM.YYYY HH24:MI:SS''';
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
                              FROM  EHEALTH_OBJECTS
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
          FROM  CSCO_CPU_MEM_DEVICE_AVG_BH CCMDABH--,
                --OBJETOS_EHEALTH OE
          --WHERE CCMDABH.NODE = OE.ELEMENT_NAME
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
    
--    SELECT  to_char(sysdate-1,'DD.MM.YYYY')
--    INTO  V_FECHA
--    FROM  DUAL;
    --
    G_ERROR_LOG_NEW.P_LOG_ERROR('P_CSCO_CPU_MEM_DEVICE_AVG_DAY',0,'NO ERROR','COMIENZO DE SUMARIZACION DAY P_CSCO_CPU_MEM_DEVICE_AVG_DAY('||P_FECHA||')');
    P_CSCO_CPU_MEM_DEVICE_AVG_DAY(P_FECHA,P_FECHA);
    G_ERROR_LOG_NEW.P_LOG_ERROR('P_CSCO_CPU_MEM_DEVICE_AVG_DAY',0,'NO ERROR','FIN DE SUMARIZACION DAY');
    --
    G_ERROR_LOG_NEW.P_LOG_ERROR('P_CSCO_CPU_MEM_DEVICE_AVG_BH',0,'NO ERROR','COMIENZO CALCULO BH P_CSCO_CPU_MEM_DEVICE_AVG_BH('||P_FECHA||')');
    P_CSCO_CPU_MEM_DEVICE_AVG_BH(P_FECHA,P_FECHA);
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
                                  to_char(to_date(P_FECHA,'DD.MM.YYYY')-7,'DD.MM.YYYY')||
                                  ' P_FECHA_SABADO => '||TO_CHAR(TO_DATE(P_FECHA,'DD.MM.YYYY')-1,'DD.MM.YYYY'));
      --
      P_CSCO_CPU_MEM_DEVICE_AVG_IBHW(to_char(to_date(P_FECHA,'DD.MM.YYYY')-7,'DD.MM.YYYY'),TO_CHAR(TO_DATE(P_FECHA,'DD.MM.YYYY')-1,'DD.MM.YYYY'));
      --
      G_ERROR_LOG_NEW.P_LOG_ERROR('P_CSCO_CPU_MEM_DEVICE_AVG_IBHW',0,'NO ERROR','FIN DE SUMARIZACION IBHW');
    END IF;
  END P_CALC_SUM_CPU_MEM_DEVICE_AVG;
  --******************************************************--
  --                     INTERFACE                        --
  --******************************************************--
  PROCEDURE P_CSCO_INTERFACE_DAY(P_FECHA_DESDE IN VARCHAR2,P_FECHA_HASTA IN VARCHAR2) AS
    --
    CURSOR CUR(FECHA_DESDE VARCHAR2,FECHA_HASTA VARCHAR2) IS
      WITH  CIH AS (SELECT  TRUNC(FECHA)                          FECHA,
                            NODE,
                            INTERFAZ,
                            IFINDEX,
                            IFTYPE,
                            LAST_VALUE(IFSPEED)
                                          OVER (PARTITION BY  TO_CHAR(FECHA,'DD.MM.YYYY'),
                                                                    NODE,
                                                                    INTERFAZ,
                                                                    IFINDEX,
                                                                    IFTYPE,
                                                                    IFTYPESTRING
                                                      ORDER BY  TO_CHAR(FECHA,'DD.MM.YYYY HH24') RANGE
                                                      BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
                                                                    ) IFSPEED,
                            SENDUTIL,
                            SENDTOTALPKTS,
                            SENDTOTALPKTRATE,
                            SENDBYTES,
                            SENDBYTERATE,
                            SENDBITRATE,
                            SENDUCASTPKTPERCENT,
                            SENDMCASTPKTPERCENT,
                            SENDBCASTPKTPERCENT,
                            SENDERRORS,
                            SENDERRORPERCENT,
                            SENDDISCARDS,
                            SENDDISCARDPERCENT,
                            RECEIVEUTIL,
                            RECEIVETOTALPKTS,
                            RECEIVETOTALPKTRATE,
                            RECEIVEBYTES,
                            RECEIVEBYTERATE,
                            RECEIVEBITRATE,
                            RECEIVEUCASTPKTPERCENT,
                            RECEIVEMCASTPKTPERCENT,
                            RECEIVEBCASTPKTPERCENT,
                            RECEIVEERRORS,
                            RECEIVEERRORPERCENT,
                            RECEIVEDISCARDS,
                            RECEIVEDISCARDPERCENT,
                            SENDBCASTPKTRATE,
                            RECEIVEBCASTPKTRATE,
                            IFTYPESTRING
                    FROM CSCO_INTERFACE_HOUR
                    WHERE TRUNC(FECHA) BETWEEN TO_DATE(FECHA_DESDE,'DD.MM.YYYY') AND TO_DATE(FECHA_HASTA,'DD.MM.YYYY') + 86399/86400
                    )    
      SELECT  TRUNC(FECHA)                          FECHA,
              NODE,
              INTERFAZ,
              IFINDEX,
              IFTYPE,
              MAX(IFSPEED) IFSPEED,
              ROUND(AVG(SENDUTIL),2)                SENDUTIL,
              ROUND(SUM(SENDTOTALPKTS),2)           SENDTOTALPKTS,
              ROUND(AVG(SENDTOTALPKTRATE),2)        SENDTOTALPKTRATE,
              ROUND(SUM(SENDBYTES),2)               SENDBYTES,
              ROUND(AVG(SENDBYTERATE),2)            SENDBYTERATE,
              ROUND(AVG(SENDBITRATE),2)             SENDBITRATE,
              ROUND(AVG(SENDUCASTPKTPERCENT),2)     SENDUCASTPKTPERCENT,
              ROUND(AVG(SENDMCASTPKTPERCENT),2)     SENDMCASTPKTPERCENT,
              ROUND(AVG(SENDBCASTPKTPERCENT),2)     SENDBCASTPKTPERCENT,
              ROUND(SUM(SENDERRORS),2)              SENDERRORS,
              ROUND(AVG(SENDERRORPERCENT),2)        SENDERRORPERCENT,
              ROUND(SUM(SENDDISCARDS),2)            SENDDISCARDS,
              ROUND(AVG(SENDDISCARDPERCENT),2)      SENDDISCARDPERCENT,
              ROUND(AVG(RECEIVEUTIL),2)             RECEIVEUTIL,
              ROUND(SUM(RECEIVETOTALPKTS),2)        RECEIVETOTALPKTS,
              ROUND(AVG(RECEIVETOTALPKTRATE),2)     RECEIVETOTALPKTRATE,
              ROUND(SUM(RECEIVEBYTES),2)            RECEIVEBYTES,
              ROUND(AVG(RECEIVEBYTERATE),2)         RECEIVEBYTERATE,
              ROUND(AVG(RECEIVEBITRATE),2)          RECEIVEBITRATE,
              ROUND(AVG(RECEIVEUCASTPKTPERCENT),2)  RECEIVEUCASTPKTPERCENT,
              ROUND(AVG(RECEIVEMCASTPKTPERCENT),2)  RECEIVEMCASTPKTPERCENT,
              ROUND(AVG(RECEIVEBCASTPKTPERCENT),2)  RECEIVEBCASTPKTPERCENT,
              ROUND(SUM(RECEIVEERRORS),2)           RECEIVEERRORS,
              ROUND(AVG(RECEIVEERRORPERCENT),2)     RECEIVEERRORPERCENT,
              ROUND(SUM(RECEIVEDISCARDS),2)         RECEIVEDISCARDS,
              ROUND(AVG(RECEIVEDISCARDPERCENT),2)   RECEIVEDISCARDPERCENT,
              ROUND(AVG(SENDBCASTPKTRATE),2)        SENDBCASTPKTRATE,
              ROUND(AVG(RECEIVEBCASTPKTRATE),2)     RECEIVEBCASTPKTRATE,
              IFTYPESTRING
      FROM CIH--CSCO_INTERFACE_HOUR
      WHERE TRUNC(FECHA) BETWEEN TO_DATE(FECHA_DESDE,'DD.MM.YYYY') AND TO_DATE(FECHA_HASTA,'DD.MM.YYYY') + 86399/86400
      GROUP BY TRUNC(FECHA),NODE,INTERFAZ,IFINDEX,IFTYPE,IFTYPESTRING;
    --
    TYPE  CSCO_INTERFACE_DAY_TAB IS TABLE OF CSCO_INTERFACE_DAY%ROWTYPE;
    V_CSCO_INTERFACE_DAY CSCO_INTERFACE_DAY_TAB;
    --
    l_errors NUMBER;
    l_errno  NUMBER;
    l_msg    VARCHAR2(4000 CHAR);
    l_idx    NUMBER;
  BEGIN
    EXECUTE IMMEDIATE 'alter session set nls_date_format = ''DD.MM.YYYY HH24:MI:SS''';
    OPEN CUR(P_FECHA_DESDE,P_FECHA_HASTA);
    LOOP
      FETCH cur BULK COLLECT INTO V_CSCO_INTERFACE_DAY LIMIT limit_in;
      BEGIN
        FORALL indice IN INDICES OF V_CSCO_INTERFACE_DAY
          --
          MERGE INTO CSCO_INTERFACE_DAY CID
          USING DUAL
          ON (CID.FECHA = V_CSCO_INTERFACE_DAY(indice).FECHA
              AND CID.NODE = V_CSCO_INTERFACE_DAY(indice).NODE
              AND CID.INTERFAZ = V_CSCO_INTERFACE_DAY(indice).INTERFAZ)
          WHEN MATCHED THEN
            UPDATE SET
              IFINDEX             = V_CSCO_INTERFACE_DAY(indice).IFINDEX,                                 
              IFTYPE              = V_CSCO_INTERFACE_DAY(indice).IFTYPE,                                   
              IFSPEED             = V_CSCO_INTERFACE_DAY(indice).IFSPEED,                                 
              SENDUTIL            = V_CSCO_INTERFACE_DAY(indice).SENDUTIL,                               
              SENDTOTALPKTS       = V_CSCO_INTERFACE_DAY(indice).SENDTOTALPKTS,                     
              SENDTOTALPKTRATE    = V_CSCO_INTERFACE_DAY(indice).SENDTOTALPKTRATE,               
              SENDBYTES           = V_CSCO_INTERFACE_DAY(indice).SENDBYTES,                             
              SENDBYTERATE        = V_CSCO_INTERFACE_DAY(indice).SENDBYTERATE,
              SENDBITRATE         = V_CSCO_INTERFACE_DAY(indice).SENDBITRATE,                         
              SENDUCASTPKTPERCENT = V_CSCO_INTERFACE_DAY(indice).SENDUCASTPKTPERCENT,         
              SENDMCASTPKTPERCENT = V_CSCO_INTERFACE_DAY(indice).SENDMCASTPKTPERCENT,         
              SENDBCASTPKTPERCENT = V_CSCO_INTERFACE_DAY(indice).SENDBCASTPKTPERCENT,         
              SENDERRORS          = V_CSCO_INTERFACE_DAY(indice).SENDERRORS,                           
              SENDERRORPERCENT    = V_CSCO_INTERFACE_DAY(indice).SENDERRORPERCENT,               
              SENDDISCARDS        = V_CSCO_INTERFACE_DAY(indice).SENDDISCARDS,                       
              SENDDISCARDPERCENT  = V_CSCO_INTERFACE_DAY(indice).SENDDISCARDPERCENT,           
              RECEIVEUTIL         = V_CSCO_INTERFACE_DAY(indice).RECEIVEUTIL,                         
              RECEIVETOTALPKTS    = V_CSCO_INTERFACE_DAY(indice).RECEIVETOTALPKTS,               
              RECEIVETOTALPKTRATE = V_CSCO_INTERFACE_DAY(indice).RECEIVETOTALPKTRATE,         
              RECEIVEBYTES        = V_CSCO_INTERFACE_DAY(indice).RECEIVEBYTES,                       
              RECEIVEBYTERATE     = V_CSCO_INTERFACE_DAY(indice).RECEIVEBYTERATE,                 
              RECEIVEBITRATE          = V_CSCO_INTERFACE_DAY(indice).RECEIVEBITRATE,                   
              RECEIVEUCASTPKTPERCENT  = V_CSCO_INTERFACE_DAY(indice).RECEIVEUCASTPKTPERCENT,   
              RECEIVEMCASTPKTPERCENT  = V_CSCO_INTERFACE_DAY(indice).RECEIVEMCASTPKTPERCENT,   
              RECEIVEBCASTPKTPERCENT  = V_CSCO_INTERFACE_DAY(indice).RECEIVEBCASTPKTPERCENT,   
              RECEIVEERRORS           = V_CSCO_INTERFACE_DAY(indice).RECEIVEERRORS,                     
              RECEIVEERRORPERCENT     = V_CSCO_INTERFACE_DAY(indice).RECEIVEERRORPERCENT,         
              RECEIVEDISCARDS         = V_CSCO_INTERFACE_DAY(indice).RECEIVEDISCARDS,                 
              RECEIVEDISCARDPERCENT   = V_CSCO_INTERFACE_DAY(indice).RECEIVEDISCARDPERCENT,     
              SENDBCASTPKTRATE        = V_CSCO_INTERFACE_DAY(indice).SENDBCASTPKTRATE,               
              RECEIVEBCASTPKTRATE     = V_CSCO_INTERFACE_DAY(indice).RECEIVEBCASTPKTRATE,         
              IFTYPESTRING            = V_CSCO_INTERFACE_DAY(indice).IFTYPESTRING
          WHEN NOT MATCHED THEN
            INSERT(FECHA,NODE,INTERFAZ,IFINDEX,IFTYPE,IFSPEED,SENDUTIL,SENDTOTALPKTS,SENDTOTALPKTRATE,SENDBYTES,
                  SENDBYTERATE,SENDBITRATE,SENDUCASTPKTPERCENT,SENDMCASTPKTPERCENT,SENDBCASTPKTPERCENT,SENDERRORS,
                  SENDERRORPERCENT,SENDDISCARDS,SENDDISCARDPERCENT,RECEIVEUTIL,RECEIVETOTALPKTS,RECEIVETOTALPKTRATE,
                  RECEIVEBYTES,RECEIVEBYTERATE,RECEIVEBITRATE,RECEIVEUCASTPKTPERCENT,RECEIVEMCASTPKTPERCENT,
                  RECEIVEBCASTPKTPERCENT,RECEIVEERRORS,RECEIVEERRORPERCENT,RECEIVEDISCARDS,RECEIVEDISCARDPERCENT, 
                  SENDBCASTPKTRATE,RECEIVEBCASTPKTRATE,IFTYPESTRING)
            VALUES (V_CSCO_INTERFACE_DAY(indice).FECHA,V_CSCO_INTERFACE_DAY(indice).NODE, 
                    V_CSCO_INTERFACE_DAY(indice).INTERFAZ,V_CSCO_INTERFACE_DAY(indice).IFINDEX, 
                    V_CSCO_INTERFACE_DAY(indice).IFTYPE,V_CSCO_INTERFACE_DAY(indice).IFSPEED,
                    V_CSCO_INTERFACE_DAY(indice).SENDUTIL,V_CSCO_INTERFACE_DAY(indice).SENDTOTALPKTS,
                    V_CSCO_INTERFACE_DAY(indice).SENDTOTALPKTRATE,V_CSCO_INTERFACE_DAY(indice).SENDBYTES,    
                    V_CSCO_INTERFACE_DAY(indice).SENDBYTERATE,V_CSCO_INTERFACE_DAY(indice).SENDBITRATE,  
                    V_CSCO_INTERFACE_DAY(indice).SENDUCASTPKTPERCENT,V_CSCO_INTERFACE_DAY(indice).SENDMCASTPKTPERCENT,                               
                    V_CSCO_INTERFACE_DAY(indice).SENDBCASTPKTPERCENT,V_CSCO_INTERFACE_DAY(indice).SENDERRORS,   
                    V_CSCO_INTERFACE_DAY(indice).SENDERRORPERCENT,V_CSCO_INTERFACE_DAY(indice).SENDDISCARDS, 
                    V_CSCO_INTERFACE_DAY(indice).SENDDISCARDPERCENT,V_CSCO_INTERFACE_DAY(indice).RECEIVEUTIL,  
                    V_CSCO_INTERFACE_DAY(indice).RECEIVETOTALPKTS,V_CSCO_INTERFACE_DAY(indice).RECEIVETOTALPKTRATE,                               
                    V_CSCO_INTERFACE_DAY(indice).RECEIVEBYTES,V_CSCO_INTERFACE_DAY(indice).RECEIVEBYTERATE,
                    V_CSCO_INTERFACE_DAY(indice).RECEIVEBITRATE,V_CSCO_INTERFACE_DAY(indice).RECEIVEUCASTPKTPERCENT,                            
                    V_CSCO_INTERFACE_DAY(indice).RECEIVEMCASTPKTPERCENT,V_CSCO_INTERFACE_DAY(indice).RECEIVEBCASTPKTPERCENT,                            
                    V_CSCO_INTERFACE_DAY(indice).RECEIVEERRORS,V_CSCO_INTERFACE_DAY(indice).RECEIVEERRORPERCENT,                               
                    V_CSCO_INTERFACE_DAY(indice).RECEIVEDISCARDS,V_CSCO_INTERFACE_DAY(indice).RECEIVEDISCARDPERCENT,                             
                    V_CSCO_INTERFACE_DAY(indice).SENDBCASTPKTRATE,V_CSCO_INTERFACE_DAY(indice).RECEIVEBCASTPKTRATE,                               
                    V_CSCO_INTERFACE_DAY(indice).IFTYPESTRING);
        EXCEPTION
          WHEN OTHERS THEN
            L_ERRORS := SQL%BULK_EXCEPTIONS.COUNT;
            FOR indice IN 1 .. L_ERRORS
            LOOP
              L_ERRNO := SQL%BULK_EXCEPTIONS(indice).ERROR_CODE;
              L_MSG   := SQLERRM(-L_ERRNO);
              L_IDX   := SQL%BULK_EXCEPTIONS(indice).ERROR_INDEX;
              --
              g_error_log_new.P_LOG_ERROR('P_CSCO_INTERFACE_DAY',
                                          L_ERRNO,
                                          L_MSG,
                                          'FECHA => '                   ||V_CSCO_INTERFACE_DAY(L_IDX).FECHA||
                                          ' NODE => '                   ||V_CSCO_INTERFACE_DAY(L_IDX).NODE||
                                          ' INTERFAZ => '               ||V_CSCO_INTERFACE_DAY(L_IDX).INTERFAZ||
                                          ' IFINDEX => '                ||TO_CHAR(V_CSCO_INTERFACE_DAY(L_IDX).IFINDEX)||
                                          ' IFTYPE => '                 ||TO_CHAR(V_CSCO_INTERFACE_DAY(L_IDX).IFTYPE)||
                                          ' IFSPEED => '                ||TO_CHAR(V_CSCO_INTERFACE_DAY(L_IDX).IFSPEED)||
                                          ' SENDUTIL => '               ||TO_CHAR(V_CSCO_INTERFACE_DAY(L_IDX).SENDUTIL)||
                                          ' SENDTOTALPKTS => '          ||TO_CHAR(V_CSCO_INTERFACE_DAY(L_IDX).SENDTOTALPKTS)||
                                          ' SENDTOTALPKTRATE => '       ||TO_CHAR(V_CSCO_INTERFACE_DAY(L_IDX).SENDTOTALPKTRATE)||
                                          ' SENDBYTES => '              ||TO_CHAR(V_CSCO_INTERFACE_DAY(L_IDX).SENDBYTES)||
                                          ' SENDBYTERATE => '           ||TO_CHAR(V_CSCO_INTERFACE_DAY(L_IDX).SENDBYTERATE)||
                                          ' SENDBITRATE => '            ||TO_CHAR(V_CSCO_INTERFACE_DAY(L_IDX).SENDBITRATE)||
                                          ' SENDUCASTPKTPERCENT => '    ||TO_CHAR(V_CSCO_INTERFACE_DAY(L_IDX).SENDUCASTPKTPERCENT)||
                                          ' SENDMCASTPKTPERCENT => '    ||TO_CHAR(V_CSCO_INTERFACE_DAY(L_IDX).SENDMCASTPKTPERCENT)||
                                          ' SENDBCASTPKTPERCENT => '    ||TO_CHAR(V_CSCO_INTERFACE_DAY(L_IDX).SENDBCASTPKTPERCENT)||
                                          ' SENDERRORS => '             ||TO_CHAR(V_CSCO_INTERFACE_DAY(L_IDX).SENDERRORS)||
                                          ' SENDERRORPERCENT => '       ||TO_CHAR(V_CSCO_INTERFACE_DAY(L_IDX).SENDERRORPERCENT)||
                                          ' SENDDISCARDS => '           ||TO_CHAR(V_CSCO_INTERFACE_DAY(L_IDX).SENDDISCARDS)||
                                          ' SENDDISCARDPERCENT => '     ||TO_CHAR(V_CSCO_INTERFACE_DAY(L_IDX).SENDDISCARDPERCENT)||
                                          ' RECEIVEUTIL => '            ||TO_CHAR(V_CSCO_INTERFACE_DAY(L_IDX).RECEIVEUTIL)||
                                          ' RECEIVETOTALPKTS => '       ||TO_CHAR(V_CSCO_INTERFACE_DAY(L_IDX).RECEIVETOTALPKTS)||
                                          ' RECEIVETOTALPKTRATE => '    ||TO_CHAR(V_CSCO_INTERFACE_DAY(L_IDX).RECEIVETOTALPKTRATE)||
                                          ' RECEIVEBYTES => '           ||TO_CHAR(V_CSCO_INTERFACE_DAY(L_IDX).RECEIVEBYTES)||
                                          ' RECEIVEBYTERATE => '        ||TO_CHAR(V_CSCO_INTERFACE_DAY(L_IDX).RECEIVEBYTERATE)||
                                          ' RECEIVEBITRATE => '         ||TO_CHAR(V_CSCO_INTERFACE_DAY(L_IDX).RECEIVEBITRATE)||
                                          ' RECEIVEUCASTPKTPERCENT => ' ||TO_CHAR(V_CSCO_INTERFACE_DAY(L_IDX).RECEIVEUCASTPKTPERCENT)||
                                          ' RECEIVEMCASTPKTPERCENT => ' ||TO_CHAR(V_CSCO_INTERFACE_DAY(L_IDX).RECEIVEMCASTPKTPERCENT)||
                                          ' RECEIVEBCASTPKTPERCENT => ' ||TO_CHAR(V_CSCO_INTERFACE_DAY(L_IDX).RECEIVEBCASTPKTPERCENT)||
                                          ' RECEIVEERRORS => '          ||TO_CHAR(V_CSCO_INTERFACE_DAY(L_IDX).RECEIVEERRORS)||
                                          ' RECEIVEERRORPERCENT => '    ||TO_CHAR(V_CSCO_INTERFACE_DAY(L_IDX).RECEIVEERRORPERCENT)||
                                          ' RECEIVEDISCARDS => '        ||TO_CHAR(V_CSCO_INTERFACE_DAY(L_IDX).RECEIVEDISCARDS)||
                                          ' RECEIVEDISCARDPERCENT => '  ||TO_CHAR(V_CSCO_INTERFACE_DAY(L_IDX).RECEIVEDISCARDPERCENT)||
                                          ' SENDBCASTPKTRATE => '       ||TO_CHAR(V_CSCO_INTERFACE_DAY(L_IDX).SENDBCASTPKTRATE)||
                                          ' RECEIVEBCASTPKTRATE => '    ||TO_CHAR(V_CSCO_INTERFACE_DAY(L_IDX).RECEIVEBCASTPKTRATE)||
                                          ' IFTYPESTRING => '           ||V_CSCO_INTERFACE_DAY(L_IDX).IFTYPESTRING);
            END LOOP;
      END;
      EXIT WHEN cur%NOTFOUND;
    END LOOP;
    COMMIT;
    CLOSE cur;
    
    EXCEPTION
      WHEN OTHERS THEN
        g_error_log_new.P_LOG_ERROR('P_CSCO_INTERFACE_DAY',
                                    SQLCODE,
                                    SQLERRM,
                                    'Fallo al insertar los datos');
  END P_CSCO_INTERFACE_DAY;
  --**--**--**--**--
  PROCEDURE P_CSCO_INTERFACE_BH(P_FECHA_DESDE IN VARCHAR2,P_FECHA_HASTA IN VARCHAR2) AS
   --
    CURSOR CUR(FECHA_DESDE VARCHAR2,FECHA_HASTA VARCHAR2) IS
    SELECT  FECHA,NODE,INTERFAZ,IFINDEX,IFTYPE,IFSPEED,SENDUTIL,SENDTOTALPKTS,SENDTOTALPKTRATE,SENDBYTES,SENDBYTERATE,
            SENDBITRATE,SENDUCASTPKTPERCENT,SENDMCASTPKTPERCENT,SENDBCASTPKTPERCENT,SENDERRORS,SENDERRORPERCENT,
            SENDDISCARDS,SENDDISCARDPERCENT,RECEIVEUTIL,RECEIVETOTALPKTS,RECEIVETOTALPKTRATE,RECEIVEBYTES,
            RECEIVEBYTERATE,RECEIVEBITRATE,RECEIVEUCASTPKTPERCENT,RECEIVEMCASTPKTPERCENT,RECEIVEBCASTPKTPERCENT,
            RECEIVEERRORS,RECEIVEERRORPERCENT,RECEIVEDISCARDS,RECEIVEDISCARDPERCENT,SENDBCASTPKTRATE,RECEIVEBCASTPKTRATE,
            IFTYPESTRING,MAX_SEND_RECEIVE
    FROM (
          SELECT  TO_CHAR(FECHA,'DD.MM.YYYY HH24') FECHA,NODE,INTERFAZ,IFINDEX,IFTYPE,IFSPEED,SENDUTIL,SENDTOTALPKTS,
                  SENDTOTALPKTRATE,SENDBYTES,SENDBYTERATE,SENDBITRATE,SENDUCASTPKTPERCENT,SENDMCASTPKTPERCENT,
                  SENDBCASTPKTPERCENT,SENDERRORS,SENDERRORPERCENT,SENDDISCARDS,SENDDISCARDPERCENT,RECEIVEUTIL,
                  RECEIVETOTALPKTS,RECEIVETOTALPKTRATE,RECEIVEBYTES,RECEIVEBYTERATE,RECEIVEBITRATE,RECEIVEUCASTPKTPERCENT,
                  RECEIVEMCASTPKTPERCENT,RECEIVEBCASTPKTPERCENT,RECEIVEERRORS,RECEIVEERRORPERCENT,RECEIVEDISCARDS,
                  RECEIVEDISCARDPERCENT,SENDBCASTPKTRATE,RECEIVEBCASTPKTRATE,IFTYPESTRING,MAX_SEND_RECEIVE,
                  ROW_NUMBER() OVER (PARTITION BY TRUNC(FECHA),
                                                  NODE,
                                                  INTERFAZ,
                                                  IFINDEX,
                                                  IFTYPE,
                                                  IFTYPESTRING
                                      ORDER BY MAX_SEND_RECEIVE DESC) SEQNUM
          FROM CSCO_INTERFACE_HOUR
          WHERE TRUNC(FECHA) BETWEEN TO_DATE(FECHA_DESDE, 'DD.MM.YYYY')
                           AND TO_DATE(FECHA_HASTA, 'DD.MM.YYYY') + 86399/86400
          --AND NODE = 'CRR-PE-R02'
          --AND INTERFAZ = 'GigabitEthernet2/40'
          )
    WHERE SEQNUM = 1;
    --
    TYPE  CSCO_INTERFACE_BH_TAB IS TABLE OF CSCO_INTERFACE_BH%ROWTYPE;
    V_CSCO_INTERFACE_BH CSCO_INTERFACE_BH_TAB;
    --
    l_errors NUMBER;
    l_errno  NUMBER;
    l_msg    VARCHAR2(4000 CHAR);
    l_idx    NUMBER;
  BEGIN
    EXECUTE IMMEDIATE 'alter session set nls_date_format = ''DD.MM.YYYY HH24:MI:SS''';
    -- Limpio la fecha de BH que se esta calculando
    BEGIN
      DELETE FROM CSCO_INTERFACE_BH CIB
      WHERE TO_CHAR(CIB.FECHA,'DD.MM.YYYY') = P_FECHA_DESDE;
      --
      COMMIT;
      --
      EXCEPTION
        WHEN OTHERS THEN
          g_error_log_new.P_LOG_ERROR('P_CSCO_INTERFACE_BH',
                                      SQLCODE,
                                      SQLERRM,
                                      'Fallo al limpiar los datos IBHW');
    END;
    --
    OPEN CUR(P_FECHA_DESDE,P_FECHA_HASTA);
    LOOP
      FETCH cur BULK COLLECT INTO V_CSCO_INTERFACE_BH LIMIT limit_in;
      BEGIN
        FORALL indice IN INDICES OF V_CSCO_INTERFACE_BH
          --
          MERGE INTO CSCO_INTERFACE_BH CIB
          USING DUAL
          ON (CIB.FECHA                       = V_CSCO_INTERFACE_BH(indice).FECHA
              AND CIB.NODE                    = V_CSCO_INTERFACE_BH(indice).NODE
              AND CIB.INTERFAZ                = V_CSCO_INTERFACE_BH(indice).INTERFAZ)
          WHEN MATCHED THEN
            UPDATE SET
              IFINDEX                 = V_CSCO_INTERFACE_BH(indice).IFINDEX,                                 
              IFTYPE                  = V_CSCO_INTERFACE_BH(indice).IFTYPE,                                   
              IFSPEED                 = V_CSCO_INTERFACE_BH(indice).IFSPEED,                                 
              SENDUTIL                = V_CSCO_INTERFACE_BH(indice).SENDUTIL,                               
              SENDTOTALPKTS           = V_CSCO_INTERFACE_BH(indice).SENDTOTALPKTS,                     
              SENDTOTALPKTRATE        = V_CSCO_INTERFACE_BH(indice).SENDTOTALPKTRATE,               
              SENDBYTES               = V_CSCO_INTERFACE_BH(indice).SENDBYTES,                             
              SENDBYTERATE            = V_CSCO_INTERFACE_BH(indice).SENDBYTERATE,
              SENDBITRATE             = V_CSCO_INTERFACE_BH(indice).SENDBITRATE,                         
              SENDUCASTPKTPERCENT     = V_CSCO_INTERFACE_BH(indice).SENDUCASTPKTPERCENT,         
              SENDMCASTPKTPERCENT     = V_CSCO_INTERFACE_BH(indice).SENDMCASTPKTPERCENT,         
              SENDBCASTPKTPERCENT     = V_CSCO_INTERFACE_BH(indice).SENDBCASTPKTPERCENT,         
              SENDERRORS              = V_CSCO_INTERFACE_BH(indice).SENDERRORS,                           
              SENDERRORPERCENT        = V_CSCO_INTERFACE_BH(indice).SENDERRORPERCENT,               
              SENDDISCARDS            = V_CSCO_INTERFACE_BH(indice).SENDDISCARDS,                       
              SENDDISCARDPERCENT      = V_CSCO_INTERFACE_BH(indice).SENDDISCARDPERCENT,           
              RECEIVEUTIL             = V_CSCO_INTERFACE_BH(indice).RECEIVEUTIL,                         
              RECEIVETOTALPKTS        = V_CSCO_INTERFACE_BH(indice).RECEIVETOTALPKTS,               
              RECEIVETOTALPKTRATE     = V_CSCO_INTERFACE_BH(indice).RECEIVETOTALPKTRATE,         
              RECEIVEBYTES            = V_CSCO_INTERFACE_BH(indice).RECEIVEBYTES,                       
              RECEIVEBYTERATE         = V_CSCO_INTERFACE_BH(indice).RECEIVEBYTERATE,                 
              RECEIVEBITRATE          = V_CSCO_INTERFACE_BH(indice).RECEIVEBITRATE,                   
              RECEIVEUCASTPKTPERCENT  = V_CSCO_INTERFACE_BH(indice).RECEIVEUCASTPKTPERCENT,   
              RECEIVEMCASTPKTPERCENT  = V_CSCO_INTERFACE_BH(indice).RECEIVEMCASTPKTPERCENT,   
              RECEIVEBCASTPKTPERCENT  = V_CSCO_INTERFACE_BH(indice).RECEIVEBCASTPKTPERCENT,   
              RECEIVEERRORS           = V_CSCO_INTERFACE_BH(indice).RECEIVEERRORS,                     
              RECEIVEERRORPERCENT     = V_CSCO_INTERFACE_BH(indice).RECEIVEERRORPERCENT,         
              RECEIVEDISCARDS         = V_CSCO_INTERFACE_BH(indice).RECEIVEDISCARDS,                 
              RECEIVEDISCARDPERCENT   = V_CSCO_INTERFACE_BH(indice).RECEIVEDISCARDPERCENT,     
              SENDBCASTPKTRATE        = V_CSCO_INTERFACE_BH(indice).SENDBCASTPKTRATE,               
              RECEIVEBCASTPKTRATE     = V_CSCO_INTERFACE_BH(indice).RECEIVEBCASTPKTRATE,         
              IFTYPESTRING            = V_CSCO_INTERFACE_BH(indice).IFTYPESTRING,
              MAX_SEND_RECEIVE        = V_CSCO_INTERFACE_BH(indice).MAX_SEND_RECEIVE
          WHEN NOT MATCHED THEN         
            INSERT(FECHA,NODE,INTERFAZ,IFINDEX,IFTYPE,IFSPEED,SENDUTIL,SENDTOTALPKTS,SENDTOTALPKTRATE,SENDBYTES,
                  SENDBYTERATE,SENDBITRATE,SENDUCASTPKTPERCENT,SENDMCASTPKTPERCENT,SENDBCASTPKTPERCENT,SENDERRORS,
                  SENDERRORPERCENT,SENDDISCARDS,SENDDISCARDPERCENT,RECEIVEUTIL,RECEIVETOTALPKTS,RECEIVETOTALPKTRATE,
                  RECEIVEBYTES,RECEIVEBYTERATE,RECEIVEBITRATE,RECEIVEUCASTPKTPERCENT,RECEIVEMCASTPKTPERCENT,
                  RECEIVEBCASTPKTPERCENT,RECEIVEERRORS,RECEIVEERRORPERCENT,RECEIVEDISCARDS,RECEIVEDISCARDPERCENT, 
                  SENDBCASTPKTRATE,RECEIVEBCASTPKTRATE,IFTYPESTRING,MAX_SEND_RECEIVE)
            VALUES (V_CSCO_INTERFACE_BH(indice).FECHA,V_CSCO_INTERFACE_BH(indice).NODE, 
                    V_CSCO_INTERFACE_BH(indice).INTERFAZ,V_CSCO_INTERFACE_BH(indice).IFINDEX, 
                    V_CSCO_INTERFACE_BH(indice).IFTYPE,V_CSCO_INTERFACE_BH(indice).IFSPEED,
                    V_CSCO_INTERFACE_BH(indice).SENDUTIL,V_CSCO_INTERFACE_BH(indice).SENDTOTALPKTS,
                    V_CSCO_INTERFACE_BH(indice).SENDTOTALPKTRATE,V_CSCO_INTERFACE_BH(indice).SENDBYTES,    
                    V_CSCO_INTERFACE_BH(indice).SENDBYTERATE,V_CSCO_INTERFACE_BH(indice).SENDBITRATE,  
                    V_CSCO_INTERFACE_BH(indice).SENDUCASTPKTPERCENT,V_CSCO_INTERFACE_BH(indice).SENDMCASTPKTPERCENT,                               
                    V_CSCO_INTERFACE_BH(indice).SENDBCASTPKTPERCENT,V_CSCO_INTERFACE_BH(indice).SENDERRORS,   
                    V_CSCO_INTERFACE_BH(indice).SENDERRORPERCENT,V_CSCO_INTERFACE_BH(indice).SENDDISCARDS, 
                    V_CSCO_INTERFACE_BH(indice).SENDDISCARDPERCENT,V_CSCO_INTERFACE_BH(indice).RECEIVEUTIL,  
                    V_CSCO_INTERFACE_BH(indice).RECEIVETOTALPKTS,V_CSCO_INTERFACE_BH(indice).RECEIVETOTALPKTRATE,                               
                    V_CSCO_INTERFACE_BH(indice).RECEIVEBYTES,V_CSCO_INTERFACE_BH(indice).RECEIVEBYTERATE,
                    V_CSCO_INTERFACE_BH(indice).RECEIVEBITRATE,V_CSCO_INTERFACE_BH(indice).RECEIVEUCASTPKTPERCENT,                            
                    V_CSCO_INTERFACE_BH(indice).RECEIVEMCASTPKTPERCENT,V_CSCO_INTERFACE_BH(indice).RECEIVEBCASTPKTPERCENT,                            
                    V_CSCO_INTERFACE_BH(indice).RECEIVEERRORS,V_CSCO_INTERFACE_BH(indice).RECEIVEERRORPERCENT,                               
                    V_CSCO_INTERFACE_BH(indice).RECEIVEDISCARDS,V_CSCO_INTERFACE_BH(indice).RECEIVEDISCARDPERCENT,                             
                    V_CSCO_INTERFACE_BH(indice).SENDBCASTPKTRATE,V_CSCO_INTERFACE_BH(indice).RECEIVEBCASTPKTRATE,                               
                    V_CSCO_INTERFACE_BH(indice).IFTYPESTRING,V_CSCO_INTERFACE_BH(indice).MAX_SEND_RECEIVE);
        EXCEPTION
          WHEN OTHERS THEN
            L_ERRORS := SQL%BULK_EXCEPTIONS.COUNT;
            FOR indice IN 1 .. L_ERRORS
            LOOP
              L_ERRNO := SQL%BULK_EXCEPTIONS(indice).ERROR_CODE;
              L_MSG   := SQLERRM(-L_ERRNO);
              L_IDX   := SQL%BULK_EXCEPTIONS(indice).ERROR_INDEX;
              --
              g_error_log_new.P_LOG_ERROR('P_CSCO_INTERFACE_BH',
                                          L_ERRNO,
                                          L_MSG,
                                          'FECHA => '                   ||V_CSCO_INTERFACE_BH(L_IDX).FECHA||
                                          ' NODE => '                   ||V_CSCO_INTERFACE_BH(L_IDX).NODE||
                                          ' INTERFAZ => '               ||V_CSCO_INTERFACE_BH(L_IDX).INTERFAZ||
                                          ' IFINDEX => '                ||TO_CHAR(V_CSCO_INTERFACE_BH(L_IDX).IFINDEX)||
                                          ' IFTYPE => '                 ||TO_CHAR(V_CSCO_INTERFACE_BH(L_IDX).IFTYPE)||
                                          ' IFSPEED => '                ||TO_CHAR(V_CSCO_INTERFACE_BH(L_IDX).IFSPEED)||
                                          ' SENDUTIL => '               ||TO_CHAR(V_CSCO_INTERFACE_BH(L_IDX).SENDUTIL)||
                                          ' SENDTOTALPKTS => '          ||TO_CHAR(V_CSCO_INTERFACE_BH(L_IDX).SENDTOTALPKTS)||
                                          ' SENDTOTALPKTRATE => '       ||TO_CHAR(V_CSCO_INTERFACE_BH(L_IDX).SENDTOTALPKTRATE)||
                                          ' SENDBYTES => '              ||TO_CHAR(V_CSCO_INTERFACE_BH(L_IDX).SENDBYTES)||
                                          ' SENDBYTERATE => '           ||TO_CHAR(V_CSCO_INTERFACE_BH(L_IDX).SENDBYTERATE)||
                                          ' SENDBITRATE => '            ||TO_CHAR(V_CSCO_INTERFACE_BH(L_IDX).SENDBITRATE)||
                                          ' SENDUCASTPKTPERCENT => '    ||TO_CHAR(V_CSCO_INTERFACE_BH(L_IDX).SENDUCASTPKTPERCENT)||
                                          ' SENDMCASTPKTPERCENT => '    ||TO_CHAR(V_CSCO_INTERFACE_BH(L_IDX).SENDMCASTPKTPERCENT)||
                                          ' SENDBCASTPKTPERCENT => '    ||TO_CHAR(V_CSCO_INTERFACE_BH(L_IDX).SENDBCASTPKTPERCENT)||
                                          ' SENDERRORS => '             ||TO_CHAR(V_CSCO_INTERFACE_BH(L_IDX).SENDERRORS)||
                                          ' SENDERRORPERCENT => '       ||TO_CHAR(V_CSCO_INTERFACE_BH(L_IDX).SENDERRORPERCENT)||
                                          ' SENDDISCARDS => '           ||TO_CHAR(V_CSCO_INTERFACE_BH(L_IDX).SENDDISCARDS)||
                                          ' SENDDISCARDPERCENT => '     ||TO_CHAR(V_CSCO_INTERFACE_BH(L_IDX).SENDDISCARDPERCENT)||
                                          ' RECEIVEUTIL => '            ||TO_CHAR(V_CSCO_INTERFACE_BH(L_IDX).RECEIVEUTIL)||
                                          ' RECEIVETOTALPKTS => '       ||TO_CHAR(V_CSCO_INTERFACE_BH(L_IDX).RECEIVETOTALPKTS)||
                                          ' RECEIVETOTALPKTRATE => '    ||TO_CHAR(V_CSCO_INTERFACE_BH(L_IDX).RECEIVETOTALPKTRATE)||
                                          ' RECEIVEBYTES => '           ||TO_CHAR(V_CSCO_INTERFACE_BH(L_IDX).RECEIVEBYTES)||
                                          ' RECEIVEBYTERATE => '        ||TO_CHAR(V_CSCO_INTERFACE_BH(L_IDX).RECEIVEBYTERATE)||
                                          ' RECEIVEBITRATE => '         ||TO_CHAR(V_CSCO_INTERFACE_BH(L_IDX).RECEIVEBITRATE)||
                                          ' RECEIVEUCASTPKTPERCENT => ' ||TO_CHAR(V_CSCO_INTERFACE_BH(L_IDX).RECEIVEUCASTPKTPERCENT)||
                                          ' RECEIVEMCASTPKTPERCENT => ' ||TO_CHAR(V_CSCO_INTERFACE_BH(L_IDX).RECEIVEMCASTPKTPERCENT)||
                                          ' RECEIVEBCASTPKTPERCENT => ' ||TO_CHAR(V_CSCO_INTERFACE_BH(L_IDX).RECEIVEBCASTPKTPERCENT)||
                                          ' RECEIVEERRORS => '          ||TO_CHAR(V_CSCO_INTERFACE_BH(L_IDX).RECEIVEERRORS)||
                                          ' RECEIVEERRORPERCENT => '    ||TO_CHAR(V_CSCO_INTERFACE_BH(L_IDX).RECEIVEERRORPERCENT)||
                                          ' RECEIVEDISCARDS => '        ||TO_CHAR(V_CSCO_INTERFACE_BH(L_IDX).RECEIVEDISCARDS)||
                                          ' RECEIVEDISCARDPERCENT => '  ||TO_CHAR(V_CSCO_INTERFACE_BH(L_IDX).RECEIVEDISCARDPERCENT)||
                                          ' SENDBCASTPKTRATE => '       ||TO_CHAR(V_CSCO_INTERFACE_BH(L_IDX).SENDBCASTPKTRATE)||
                                          ' RECEIVEBCASTPKTRATE => '    ||TO_CHAR(V_CSCO_INTERFACE_BH(L_IDX).RECEIVEBCASTPKTRATE)||
                                          ' IFTYPESTRING => '           ||V_CSCO_INTERFACE_BH(L_IDX).IFTYPESTRING||
                                          ' MAX_SEND_RECEIVE => '       ||TO_CHAR(V_CSCO_INTERFACE_BH(indice).MAX_SEND_RECEIVE));
            END LOOP;
      END;
      EXIT WHEN cur%NOTFOUND;
    END LOOP;
    COMMIT;
    CLOSE cur;
    
    EXCEPTION
      WHEN OTHERS THEN
        g_error_log_new.P_LOG_ERROR('P_CSCO_INTERFACE_BH',
                                    SQLCODE,
                                    SQLERRM,
                                    'Fallo al insertar los datos');
  END P_CSCO_INTERFACE_BH;
  --**--**--**--
  PROCEDURE P_CSCO_INTERFACE_IBHW(P_FECHA_DESDE IN VARCHAR2,P_FECHA_HASTA IN VARCHAR2) AS
    --
    CURSOR CUR(FECHA_DESDE VARCHAR2,FECHA_HASTA VARCHAR2) IS
    SELECT  FECHA_DESDE FECHA,  
            NODE,    
            INTERFAZ,                      
            IFINDEX,                        
            IFTYPE,
            ROUND(AVG(IFSPEED),2)                 IFSPEED,                        
            ROUND(AVG(SENDUTIL),2)                SENDUTIL,                      
            ROUND(AVG(SENDTOTALPKTS),2)           SENDTOTALPKTS,            
            ROUND(AVG(SENDTOTALPKTRATE),2)        SENDTOTALPKTRATE,      
            ROUND(AVG(SENDBYTES),2)               SENDBYTES,                    
            ROUND(AVG(SENDBYTERATE),2)            SENDBYTERATE,              
            ROUND(AVG(SENDBITRATE),2)             SENDBITRATE,                
            ROUND(AVG(SENDUCASTPKTPERCENT),2)     SENDUCASTPKTPERCENT,
            ROUND(AVG(SENDMCASTPKTPERCENT),2)     SENDMCASTPKTPERCENT,
            ROUND(AVG(SENDBCASTPKTPERCENT),2)     SENDBCASTPKTPERCENT,
            ROUND(AVG(SENDERRORS),2)              SENDERRORS,                  
            ROUND(AVG(SENDERRORPERCENT),2)        SENDERRORPERCENT,      
            ROUND(AVG(SENDDISCARDS),2)            SENDDISCARDS,              
            ROUND(AVG(SENDDISCARDPERCENT),2)      SENDDISCARDPERCENT,  
            ROUND(AVG(RECEIVEUTIL),2)             RECEIVEUTIL,                
            ROUND(AVG(RECEIVETOTALPKTS),2)        RECEIVETOTALPKTS,      
            ROUND(AVG(RECEIVETOTALPKTRATE),2)     RECEIVETOTALPKTRATE,
            ROUND(AVG(RECEIVEBYTES),2)            RECEIVEBYTES,              
            ROUND(AVG(RECEIVEBYTERATE),2)         RECEIVEBYTERATE,        
            ROUND(AVG(RECEIVEBITRATE),2)          RECEIVEBITRATE,          
            ROUND(AVG(RECEIVEUCASTPKTPERCENT),2)  RECEIVEUCASTPKTPERCENT,                    
            ROUND(AVG(RECEIVEMCASTPKTPERCENT),2)  RECEIVEMCASTPKTPERCENT,                    
            ROUND(AVG(RECEIVEBCASTPKTPERCENT),2)  RECEIVEBCASTPKTPERCENT,                    
            ROUND(AVG(RECEIVEERRORS),2)           RECEIVEERRORS,            
            ROUND(AVG(RECEIVEERRORPERCENT),2)     RECEIVEERRORPERCENT,
            ROUND(AVG(RECEIVEDISCARDS),2)         RECEIVEDISCARDS,        
            ROUND(AVG(RECEIVEDISCARDPERCENT),2)   RECEIVEDISCARDPERCENT,                      
            ROUND(AVG(SENDBCASTPKTRATE),2)        SENDBCASTPKTRATE,      
            ROUND(AVG(RECEIVEBCASTPKTRATE),2)     RECEIVEBCASTPKTRATE,
            IFTYPESTRING,
            ROUND(AVG(MAX_SEND_RECEIVE),2)        MAX_SEND_RECEIVE
    
    FROM (
          SELECT  TRUNC(FECHA,'DAY') FECHA,NODE,INTERFAZ,IFINDEX,IFTYPE,IFSPEED,SENDUTIL,SENDTOTALPKTS,SENDTOTALPKTRATE,SENDBYTES,
                  SENDBYTERATE,SENDBITRATE,SENDUCASTPKTPERCENT,SENDMCASTPKTPERCENT,SENDBCASTPKTPERCENT,
                  SENDERRORS,SENDERRORPERCENT,SENDDISCARDS,SENDDISCARDPERCENT,RECEIVEUTIL,RECEIVETOTALPKTS,
                  RECEIVETOTALPKTRATE,RECEIVEBYTES,RECEIVEBYTERATE,RECEIVEBITRATE,RECEIVEUCASTPKTPERCENT,
                  RECEIVEMCASTPKTPERCENT,RECEIVEBCASTPKTPERCENT,RECEIVEERRORS,RECEIVEERRORPERCENT,RECEIVEDISCARDS,
                  RECEIVEDISCARDPERCENT,SENDBCASTPKTRATE,RECEIVEBCASTPKTRATE,IFTYPESTRING,MAX_SEND_RECEIVE,
                  ROW_NUMBER() OVER (PARTITION BY TRUNC(FECHA,'DAY'),
                                                  NODE,
                                                  INTERFAZ,
                                                  IFINDEX,
                                                  IFTYPE,
                                                  IFTYPESTRING
                                      ORDER BY MAX_SEND_RECEIVE DESC) SEQNUM
          FROM CSCO_INTERFACE_BH
          )
    WHERE SEQNUM <= limit_prom
    AND TRUNC(FECHA) BETWEEN TO_DATE(FECHA_DESDE,'DD.MM.YYYY') AND TO_DATE(FECHA_HASTA,'DD.MM.YYYY') + 86399/86400
    GROUP BY  FECHA,
              NODE,
              INTERFAZ,
              IFINDEX,
              IFTYPE,
              IFTYPESTRING;
    --
    TYPE  CSCO_INTERFACE_IBHW_TAB IS TABLE OF CSCO_INTERFACE_IBHW%ROWTYPE;
    V_CSCO_INTERFACE_IBHW CSCO_INTERFACE_IBHW_TAB;
    --
    l_errors NUMBER;
    l_errno  NUMBER;
    l_msg    VARCHAR2(4000 CHAR);
    l_idx    NUMBER;
  BEGIN
    EXECUTE IMMEDIATE 'alter session set nls_date_format = ''DD.MM.YYYY HH24:MI:SS''';
    --
    -- Limpio la fecha de IBHW que se esta calculando, por que puede haber cambiado los picos de la BH
    -- que se toman en consideración para el cálculo
    BEGIN
      DELETE FROM CSCO_INTERFACE_IBHW CIB
      WHERE TO_CHAR(CIB.FECHA,'DD.MM.YYYY') = P_FECHA_DESDE;
      --
      COMMIT;
      --
      EXCEPTION
        WHEN OTHERS THEN
          g_error_log_new.P_LOG_ERROR('P_CSCO_INTERFACE_IBHW',
                                      SQLCODE,
                                      SQLERRM,
                                      'Fallo al limpiar los datos IBHW');
    END;
    --
    OPEN CUR(P_FECHA_DESDE,P_FECHA_HASTA);
    LOOP
      FETCH cur BULK COLLECT INTO V_CSCO_INTERFACE_IBHW LIMIT limit_in;
      BEGIN
        FORALL indice IN INDICES OF V_CSCO_INTERFACE_IBHW
          --
          MERGE INTO CSCO_INTERFACE_IBHW CIB
          USING DUAL
          ON (CIB.FECHA                       = V_CSCO_INTERFACE_IBHW(indice).FECHA
              AND CIB.NODE                    = V_CSCO_INTERFACE_IBHW(indice).NODE
              AND CIB.INTERFAZ                = V_CSCO_INTERFACE_IBHW(indice).INTERFAZ)
          WHEN MATCHED THEN
            UPDATE SET
              IFINDEX                 = V_CSCO_INTERFACE_IBHW(indice).IFINDEX,                                 
              IFTYPE                  = V_CSCO_INTERFACE_IBHW(indice).IFTYPE,                                   
              IFSPEED                 = V_CSCO_INTERFACE_IBHW(indice).IFSPEED,                                 
              SENDUTIL                = V_CSCO_INTERFACE_IBHW(indice).SENDUTIL,                               
              SENDTOTALPKTS           = V_CSCO_INTERFACE_IBHW(indice).SENDTOTALPKTS,                     
              SENDTOTALPKTRATE        = V_CSCO_INTERFACE_IBHW(indice).SENDTOTALPKTRATE,               
              SENDBYTES               = V_CSCO_INTERFACE_IBHW(indice).SENDBYTES,                             
              SENDBYTERATE            = V_CSCO_INTERFACE_IBHW(indice).SENDBYTERATE,
              SENDBITRATE             = V_CSCO_INTERFACE_IBHW(indice).SENDBITRATE,                         
              SENDUCASTPKTPERCENT     = V_CSCO_INTERFACE_IBHW(indice).SENDUCASTPKTPERCENT,         
              SENDMCASTPKTPERCENT     = V_CSCO_INTERFACE_IBHW(indice).SENDMCASTPKTPERCENT,         
              SENDBCASTPKTPERCENT     = V_CSCO_INTERFACE_IBHW(indice).SENDBCASTPKTPERCENT,         
              SENDERRORS              = V_CSCO_INTERFACE_IBHW(indice).SENDERRORS,                           
              SENDERRORPERCENT        = V_CSCO_INTERFACE_IBHW(indice).SENDERRORPERCENT,               
              SENDDISCARDS            = V_CSCO_INTERFACE_IBHW(indice).SENDDISCARDS,                       
              SENDDISCARDPERCENT      = V_CSCO_INTERFACE_IBHW(indice).SENDDISCARDPERCENT,           
              RECEIVEUTIL             = V_CSCO_INTERFACE_IBHW(indice).RECEIVEUTIL,                         
              RECEIVETOTALPKTS        = V_CSCO_INTERFACE_IBHW(indice).RECEIVETOTALPKTS,               
              RECEIVETOTALPKTRATE     = V_CSCO_INTERFACE_IBHW(indice).RECEIVETOTALPKTRATE,         
              RECEIVEBYTES            = V_CSCO_INTERFACE_IBHW(indice).RECEIVEBYTES,                       
              RECEIVEBYTERATE         = V_CSCO_INTERFACE_IBHW(indice).RECEIVEBYTERATE,                 
              RECEIVEBITRATE          = V_CSCO_INTERFACE_IBHW(indice).RECEIVEBITRATE,                   
              RECEIVEUCASTPKTPERCENT  = V_CSCO_INTERFACE_IBHW(indice).RECEIVEUCASTPKTPERCENT,   
              RECEIVEMCASTPKTPERCENT  = V_CSCO_INTERFACE_IBHW(indice).RECEIVEMCASTPKTPERCENT,   
              RECEIVEBCASTPKTPERCENT  = V_CSCO_INTERFACE_IBHW(indice).RECEIVEBCASTPKTPERCENT,   
              RECEIVEERRORS           = V_CSCO_INTERFACE_IBHW(indice).RECEIVEERRORS,                     
              RECEIVEERRORPERCENT     = V_CSCO_INTERFACE_IBHW(indice).RECEIVEERRORPERCENT,         
              RECEIVEDISCARDS         = V_CSCO_INTERFACE_IBHW(indice).RECEIVEDISCARDS,                 
              RECEIVEDISCARDPERCENT   = V_CSCO_INTERFACE_IBHW(indice).RECEIVEDISCARDPERCENT,     
              SENDBCASTPKTRATE        = V_CSCO_INTERFACE_IBHW(indice).SENDBCASTPKTRATE,               
              RECEIVEBCASTPKTRATE     = V_CSCO_INTERFACE_IBHW(indice).RECEIVEBCASTPKTRATE,         
              IFTYPESTRING            = V_CSCO_INTERFACE_IBHW(indice).IFTYPESTRING,
              MAX_SEND_RECEIVE        = V_CSCO_INTERFACE_IBHW(indice).MAX_SEND_RECEIVE
          WHEN NOT MATCHED THEN         
            INSERT(FECHA,NODE,INTERFAZ,IFINDEX,IFTYPE,IFSPEED,SENDUTIL,SENDTOTALPKTS,SENDTOTALPKTRATE,SENDBYTES,
                  SENDBYTERATE,SENDBITRATE,SENDUCASTPKTPERCENT,SENDMCASTPKTPERCENT,SENDBCASTPKTPERCENT,SENDERRORS,
                  SENDERRORPERCENT,SENDDISCARDS,SENDDISCARDPERCENT,RECEIVEUTIL,RECEIVETOTALPKTS,RECEIVETOTALPKTRATE,
                  RECEIVEBYTES,RECEIVEBYTERATE,RECEIVEBITRATE,RECEIVEUCASTPKTPERCENT,RECEIVEMCASTPKTPERCENT,
                  RECEIVEBCASTPKTPERCENT,RECEIVEERRORS,RECEIVEERRORPERCENT,RECEIVEDISCARDS,RECEIVEDISCARDPERCENT, 
                  SENDBCASTPKTRATE,RECEIVEBCASTPKTRATE,IFTYPESTRING,MAX_SEND_RECEIVE)
            VALUES (V_CSCO_INTERFACE_IBHW(indice).FECHA,V_CSCO_INTERFACE_IBHW(indice).NODE, 
                    V_CSCO_INTERFACE_IBHW(indice).INTERFAZ,V_CSCO_INTERFACE_IBHW(indice).IFINDEX, 
                    V_CSCO_INTERFACE_IBHW(indice).IFTYPE,V_CSCO_INTERFACE_IBHW(indice).IFSPEED,
                    V_CSCO_INTERFACE_IBHW(indice).SENDUTIL,V_CSCO_INTERFACE_IBHW(indice).SENDTOTALPKTS,
                    V_CSCO_INTERFACE_IBHW(indice).SENDTOTALPKTRATE,V_CSCO_INTERFACE_IBHW(indice).SENDBYTES,    
                    V_CSCO_INTERFACE_IBHW(indice).SENDBYTERATE,V_CSCO_INTERFACE_IBHW(indice).SENDBITRATE,  
                    V_CSCO_INTERFACE_IBHW(indice).SENDUCASTPKTPERCENT,V_CSCO_INTERFACE_IBHW(indice).SENDMCASTPKTPERCENT,                               
                    V_CSCO_INTERFACE_IBHW(indice).SENDBCASTPKTPERCENT,V_CSCO_INTERFACE_IBHW(indice).SENDERRORS,   
                    V_CSCO_INTERFACE_IBHW(indice).SENDERRORPERCENT,V_CSCO_INTERFACE_IBHW(indice).SENDDISCARDS, 
                    V_CSCO_INTERFACE_IBHW(indice).SENDDISCARDPERCENT,V_CSCO_INTERFACE_IBHW(indice).RECEIVEUTIL,  
                    V_CSCO_INTERFACE_IBHW(indice).RECEIVETOTALPKTS,V_CSCO_INTERFACE_IBHW(indice).RECEIVETOTALPKTRATE,                               
                    V_CSCO_INTERFACE_IBHW(indice).RECEIVEBYTES,V_CSCO_INTERFACE_IBHW(indice).RECEIVEBYTERATE,
                    V_CSCO_INTERFACE_IBHW(indice).RECEIVEBITRATE,V_CSCO_INTERFACE_IBHW(indice).RECEIVEUCASTPKTPERCENT,                            
                    V_CSCO_INTERFACE_IBHW(indice).RECEIVEMCASTPKTPERCENT,V_CSCO_INTERFACE_IBHW(indice).RECEIVEBCASTPKTPERCENT,                            
                    V_CSCO_INTERFACE_IBHW(indice).RECEIVEERRORS,V_CSCO_INTERFACE_IBHW(indice).RECEIVEERRORPERCENT,                               
                    V_CSCO_INTERFACE_IBHW(indice).RECEIVEDISCARDS,V_CSCO_INTERFACE_IBHW(indice).RECEIVEDISCARDPERCENT,                             
                    V_CSCO_INTERFACE_IBHW(indice).SENDBCASTPKTRATE,V_CSCO_INTERFACE_IBHW(indice).RECEIVEBCASTPKTRATE,                               
                    V_CSCO_INTERFACE_IBHW(indice).IFTYPESTRING,V_CSCO_INTERFACE_IBHW(indice).MAX_SEND_RECEIVE);
        EXCEPTION
          WHEN OTHERS THEN
            L_ERRORS := SQL%BULK_EXCEPTIONS.COUNT;
            FOR indice IN 1 .. L_ERRORS
            LOOP
              L_ERRNO := SQL%BULK_EXCEPTIONS(indice).ERROR_CODE;
              L_MSG   := SQLERRM(-L_ERRNO);
              L_IDX   := SQL%BULK_EXCEPTIONS(indice).ERROR_INDEX;
              --
              g_error_log_new.P_LOG_ERROR('P_CSCO_INTERFACE_IBHW',
                                          L_ERRNO,
                                          L_MSG,
                                          'FECHA => '                   ||V_CSCO_INTERFACE_IBHW(L_IDX).FECHA||
                                          ' NODE => '                   ||V_CSCO_INTERFACE_IBHW(L_IDX).NODE||
                                          ' INTERFAZ => '               ||V_CSCO_INTERFACE_IBHW(L_IDX).INTERFAZ||
                                          ' IFINDEX => '                ||TO_CHAR(V_CSCO_INTERFACE_IBHW(L_IDX).IFINDEX)||
                                          ' IFTYPE => '                 ||TO_CHAR(V_CSCO_INTERFACE_IBHW(L_IDX).IFTYPE)||
                                          ' IFSPEED => '                ||TO_CHAR(V_CSCO_INTERFACE_IBHW(L_IDX).IFSPEED)||
                                          ' SENDUTIL => '               ||TO_CHAR(V_CSCO_INTERFACE_IBHW(L_IDX).SENDUTIL)||
                                          ' SENDTOTALPKTS => '          ||TO_CHAR(V_CSCO_INTERFACE_IBHW(L_IDX).SENDTOTALPKTS)||
                                          ' SENDTOTALPKTRATE => '       ||TO_CHAR(V_CSCO_INTERFACE_IBHW(L_IDX).SENDTOTALPKTRATE)||
                                          ' SENDBYTES => '              ||TO_CHAR(V_CSCO_INTERFACE_IBHW(L_IDX).SENDBYTES)||
                                          ' SENDBYTERATE => '           ||TO_CHAR(V_CSCO_INTERFACE_IBHW(L_IDX).SENDBYTERATE)||
                                          ' SENDBITRATE => '            ||TO_CHAR(V_CSCO_INTERFACE_IBHW(L_IDX).SENDBITRATE)||
                                          ' SENDUCASTPKTPERCENT => '    ||TO_CHAR(V_CSCO_INTERFACE_IBHW(L_IDX).SENDUCASTPKTPERCENT)||
                                          ' SENDMCASTPKTPERCENT => '    ||TO_CHAR(V_CSCO_INTERFACE_IBHW(L_IDX).SENDMCASTPKTPERCENT)||
                                          ' SENDBCASTPKTPERCENT => '    ||TO_CHAR(V_CSCO_INTERFACE_IBHW(L_IDX).SENDBCASTPKTPERCENT)||
                                          ' SENDERRORS => '             ||TO_CHAR(V_CSCO_INTERFACE_IBHW(L_IDX).SENDERRORS)||
                                          ' SENDERRORPERCENT => '       ||TO_CHAR(V_CSCO_INTERFACE_IBHW(L_IDX).SENDERRORPERCENT)||
                                          ' SENDDISCARDS => '           ||TO_CHAR(V_CSCO_INTERFACE_IBHW(L_IDX).SENDDISCARDS)||
                                          ' SENDDISCARDPERCENT => '     ||TO_CHAR(V_CSCO_INTERFACE_IBHW(L_IDX).SENDDISCARDPERCENT)||
                                          ' RECEIVEUTIL => '            ||TO_CHAR(V_CSCO_INTERFACE_IBHW(L_IDX).RECEIVEUTIL)||
                                          ' RECEIVETOTALPKTS => '       ||TO_CHAR(V_CSCO_INTERFACE_IBHW(L_IDX).RECEIVETOTALPKTS)||
                                          ' RECEIVETOTALPKTRATE => '    ||TO_CHAR(V_CSCO_INTERFACE_IBHW(L_IDX).RECEIVETOTALPKTRATE)||
                                          ' RECEIVEBYTES => '           ||TO_CHAR(V_CSCO_INTERFACE_IBHW(L_IDX).RECEIVEBYTES)||
                                          ' RECEIVEBYTERATE => '        ||TO_CHAR(V_CSCO_INTERFACE_IBHW(L_IDX).RECEIVEBYTERATE)||
                                          ' RECEIVEBITRATE => '         ||TO_CHAR(V_CSCO_INTERFACE_IBHW(L_IDX).RECEIVEBITRATE)||
                                          ' RECEIVEUCASTPKTPERCENT => ' ||TO_CHAR(V_CSCO_INTERFACE_IBHW(L_IDX).RECEIVEUCASTPKTPERCENT)||
                                          ' RECEIVEMCASTPKTPERCENT => ' ||TO_CHAR(V_CSCO_INTERFACE_IBHW(L_IDX).RECEIVEMCASTPKTPERCENT)||
                                          ' RECEIVEBCASTPKTPERCENT => ' ||TO_CHAR(V_CSCO_INTERFACE_IBHW(L_IDX).RECEIVEBCASTPKTPERCENT)||
                                          ' RECEIVEERRORS => '          ||TO_CHAR(V_CSCO_INTERFACE_IBHW(L_IDX).RECEIVEERRORS)||
                                          ' RECEIVEERRORPERCENT => '    ||TO_CHAR(V_CSCO_INTERFACE_IBHW(L_IDX).RECEIVEERRORPERCENT)||
                                          ' RECEIVEDISCARDS => '        ||TO_CHAR(V_CSCO_INTERFACE_IBHW(L_IDX).RECEIVEDISCARDS)||
                                          ' RECEIVEDISCARDPERCENT => '  ||TO_CHAR(V_CSCO_INTERFACE_IBHW(L_IDX).RECEIVEDISCARDPERCENT)||
                                          ' SENDBCASTPKTRATE => '       ||TO_CHAR(V_CSCO_INTERFACE_IBHW(L_IDX).SENDBCASTPKTRATE)||
                                          ' RECEIVEBCASTPKTRATE => '    ||TO_CHAR(V_CSCO_INTERFACE_IBHW(L_IDX).RECEIVEBCASTPKTRATE)||
                                          ' IFTYPESTRING => '           ||V_CSCO_INTERFACE_IBHW(L_IDX).IFTYPESTRING||
                                          ' MAX_SEND_RECEIVE => '       ||TO_CHAR(V_CSCO_INTERFACE_IBHW(indice).MAX_SEND_RECEIVE));
            END LOOP;
      END;
      EXIT WHEN CUR%NOTFOUND;
    END LOOP;
    COMMIT;
    CLOSE CUR;
    
    EXCEPTION
      WHEN OTHERS THEN
        g_error_log_new.P_LOG_ERROR('P_CSCO_INTERFACE_IBHW',
                                    SQLCODE,
                                    SQLERRM,
                                    'Fallo al insertar los datos');
  END P_CSCO_INTERFACE_IBHW;
  --**--**--**--
  PROCEDURE P_CALC_SUM_INTERFACE(P_FECHA IN VARCHAR2) IS
    V_DIA     VARCHAR2(10 CHAR) := '';
    V_DOMINGO VARCHAR2(10 CHAR) := '';
    V_SABADO  VARCHAR2(10 CHAR) := '';
    V_FECHA   VARCHAR2(10 CHAR) := '';
  BEGIN
    --
    G_ERROR_LOG_NEW.P_LOG_ERROR('P_CSCO_INTERFACE_DAY',0,'NO ERROR','COMIENZO DE SUMARIZACION DAY P_CSCO_INTERFACE_DAY('||P_FECHA||')');
    P_CSCO_INTERFACE_DAY(P_FECHA,P_FECHA);
    G_ERROR_LOG_NEW.P_LOG_ERROR('P_CSCO_INTERFACE_DAY',0,'NO ERROR','FIN DE SUMARIZACION DAY');
    --
    G_ERROR_LOG_NEW.P_LOG_ERROR('P_CSCO_INTERFACE_BH',0,'NO ERROR','COMIENZO CALCULO BH P_CSCO_INTERFACE_BH('||P_FECHA||')');
    P_CSCO_INTERFACE_BH(P_FECHA,P_FECHA);
    G_ERROR_LOG_NEW.P_LOG_ERROR('P_CSCO_INTERFACE_BH',0,'NO ERROR','FIN CALCULO BH');
    --
    -- Si el dia actual es DOMINGO, entonces calcular sumarizacion IBHW de la semana anterior,
    -- siempre de domingo a sabado
    --
    SELECT TO_CHAR(TO_DATE(P_FECHA,'DD.MM.YYYY'),'DAY')
    INTO V_DIA
    FROM DUAL;
    --
    V_DOMINGO := TO_CHAR(TO_DATE(P_FECHA,'DD.MM.YYYY')-7,'DD.MM.YYYY');
    V_SABADO  := TO_CHAR(TO_DATE(P_FECHA,'DD.MM.YYYY')-1,'DD.MM.YYYY');
    --
    IF (TRIM(V_DIA) = 'SUNDAY') OR (TRIM(V_DIA) = 'DOMINGO') THEN
      G_ERROR_LOG_NEW.P_LOG_ERROR('P_CSCO_INTERFACE_IBHW',0,'NO ERROR','COMIENZO DE SUMARIZACION IBHW P_FECHA_DOMINGO => '||
                                  V_DOMINGO||
                                  ' P_FECHA_SABADO => '||V_SABADO);
      --
      P_CSCO_INTERFACE_IBHW(V_DOMINGO,V_SABADO);
      --
      G_ERROR_LOG_NEW.P_LOG_ERROR('P_CSCO_INTERFACE_IBHW',0,'NO ERROR','FIN DE SUMARIZACION IBHW');
    END IF;
  END P_CALC_SUM_INTERFACE;
  --**--**--**--
  PROCEDURE P_CALC_SUM_INTERFACE_RWK(P_FECHA IN VARCHAR2) IS
    V_DOMINGO VARCHAR2(10 CHAR) := '';
    V_SABADO  VARCHAR2(10 CHAR) := '';
  BEGIN
    --
    G_ERROR_LOG_NEW.P_LOG_ERROR('P_CSCO_INTERFACE_DAY',0,'NO ERROR','COMIENZO DE SUMARIZACION DAY P_CSCO_INTERFACE_DAY('||P_FECHA||')');
    P_CSCO_INTERFACE_DAY(P_FECHA,P_FECHA);
    G_ERROR_LOG_NEW.P_LOG_ERROR('P_CSCO_INTERFACE_DAY',0,'NO ERROR','FIN DE SUMARIZACION DAY');
    --
    G_ERROR_LOG_NEW.P_LOG_ERROR('P_CSCO_INTERFACE_BH',0,'NO ERROR','COMIENZO CALCULO BH P_CSCO_INTERFACE_BH('||P_FECHA||')');
    P_CSCO_INTERFACE_BH(P_FECHA,P_FECHA);
    G_ERROR_LOG_NEW.P_LOG_ERROR('P_CSCO_INTERFACE_BH',0,'NO ERROR','FIN CALCULO BH');
    --
    -- Verificar si hay que re-calcular IBHW
    --
    IF F_RECALCULAR_IBHW(P_FECHA) = 1 THEN
      V_DOMINGO := TO_CHAR(TO_DATE(P_FECHA,'DD.MM.YYYY')+ (1-TO_CHAR(TO_DATE(P_FECHA,'DD.MM.YYYY'),'D')),'DD.MM.YYYY'); 
      V_SABADO  := TO_CHAR(TO_DATE(P_FECHA,'DD.MM.YYYY')+ (7-TO_CHAR(TO_DATE(P_FECHA,'DD.MM.YYYY'),'D')),'DD.MM.YYYY');
      --
      G_ERROR_LOG_NEW.P_LOG_ERROR('P_CSCO_INTERFACE_IBHW',0,'NO ERROR','COMIENZO DE SUMARIZACION IBHW P_FECHA_DOMINGO => '||
                                    V_DOMINGO||
                                    ' P_FECHA_SABADO => '||V_SABADO);
      --
      P_CSCO_INTERFACE_IBHW(V_DOMINGO,V_SABADO);
      --
      G_ERROR_LOG_NEW.P_LOG_ERROR('P_CALC_SUM_INTERFACE_RWK',0,'NO ERROR','FIN DE SUMARIZACION IBHW');
    END IF;
  END P_CALC_SUM_INTERFACE_RWK;
  
END G_CISCO_PRIME;
/
