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
  PROCEDURE P_INVENTORY_INS;
  /**
  * Procedure: P_CGN_STATS_DAY_INS, calcula la sumarización de los contadores a nivel de día.
  * Param: P_FECHA_DESDE, P_FECHA_HASTA, rango de fechas para hacer la sumarización.
  */
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
  /**
  *
  */
  PROCEDURE P_CPU_MEM_DEVICE_AVG_DAY(P_FECHA IN VARCHAR2);
  
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
  PROCEDURE P_INVENTORY_INS AS
  
    CURSOR INDX IS
    SELECT  ROWNUMBER,
            SUBSTR(LINEA,6,LENGTH(LINEA)) CLAVE,
            SUBSTR(VALOR,8,LENGTH(VALOR)) VALOR
    FROM CSCO_INVENTORY_AUX
    ORDER BY ROWNUMBER;
    --
    TYPE INI_FIN IS RECORD(
      ROWNUMBER  NUMBER,
      CLAVE      VARCHAR2(30 CHAR),
      VALOR      VARCHAR2(4000 CHAR)
      );
    --
    TYPE CONTENEDOR IS TABLE OF VARCHAR2(2000 CHAR) INDEX BY VARCHAR2(30 CHAR);
    TYPE INI_FIN_TAB IS TABLE OF INI_FIN INDEX BY PLS_INTEGER;
    --
    VINIFINTAB INI_FIN_TAB;
    VCONTENEDOR CONTENEDOR;
    --
    VINDICE     VARCHAR2(30 CHAR) := '-';
    VINDICEFIN  VARCHAR2(30 CHAR) := 'InvestigationStateEnum';
    --
    vError NUMBER := 0;
    
  BEGIN
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
        insert into CSCO_INVENTORY (DEVICE,DEVICE_SERIES,ELEMENT_TYPE,IP_ADDRESS)
    values (vContenedor('DeviceName'),substr(vContenedor('DeviceSerialNumber'),1,instr(vContenedor('DeviceSerialNumber'),' ',1)),vContenedor('ElementType'),vContenedor('IP'));
        EXCEPTION
          WHEN OTHERS THEN
            G_ERROR_LOG_NEW.P_LOG_ERROR('P_INVENTORY_INS',
                                      SQLCODE,
                                      SQLERRM,
                                      'Error al insertar datos, puede que falte alguna de las columnas necesarias. Ver fila :'||to_char(vContenedor('rownumber')));
            vError := 1;
      END;
    END LOOP;
    CLOSE INDX;
    COMMIT;
    
    EXCEPTION
      WHEN OTHERS THEN
        vError := 1;
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
    WHERE trunc(csr.FECHA) BETWEEN TO_DATE(FECHA_DESDE,'dd.mm.yyyy')
    AND TO_DATE(FECHA_HASTA,'dd.mm.yyyy')
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
          SELECT to_char(fecha,'dd.mm.yyyy HH24') FECHA,
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
          WHERE trunc(fecha) BETWEEN TO_DATE(fecha_desde, 'DD.MM.YYYY')
                           AND TO_DATE(fecha_hasta, 'DD.MM.YYYY') + 86399/86400)
    WHERE seqnum = 1;
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
        SELECT  trunc(fecha,'DAY') fecha,
                node,
                cgninstanceid,
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
                row_number() OVER (PARTITION BY trunc(fecha,'DAY'),
                                                node,
                                                cgninstanceid
                                      ORDER BY (ACTIVETRANSLATIONS) DESC,
                                               trunc(fecha) DESC NULLS LAST) seqnum
        from CSCO_CGN_STATS_BH)--BH
  where SEQNUM <= LIMIT_PROM
  AND fecha BETWEEN to_date(fecha_desde,'dd.mm.yyyy') AND to_date(fecha_hasta,'dd.mm.yyyy')
  GROUP BY fecha,node,cgninstanceid;
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
  BEGIN
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
    SELECT TO_CHAR(TO_DATE(P_FECHA,'DD.MM.YYYY'),'DAY')
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
  --**--**--**-
  PROCEDURE P_CPU_MEM_DEVICE_AVG_DAY(P_FECHA IN VARCHAR2) AS
    --
    TYPE t_cpu_mem_dev_avg_tab IS TABLE OF CSCO_CPU_MEM_DEVICE_AVG_DAY%ROWTYPE;
    v_cpu_mem_dev_avg_tab t_cpu_mem_dev_avg_tab;
    --
    l_errors NUMBER;
    l_errno  NUMBER;
    l_msg    VARCHAR2(4000 CHAR);
    l_idx    NUMBER;
    --
    CURSOR cur (P_FECHA VARCHAR2) IS
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
    WHERE trunc(FECHA) = TO_DATE(P_FECHA,'DD.MM.YYYY')
    --node = 'AMB037-AGG-03'
    GROUP BY trunc(FECHA),NODE;
    --
  BEGIN
    OPEN cur(P_FECHA);
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
              g_error_log_new.P_LOG_ERROR('P_CPU_MEM_DEVICE_AVG_DAY',
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
        g_error_log_new.P_LOG_ERROR('P_CPU_MEM_DEVICE_AVG_DAY',
                                    SQLCODE,
                                    SQLERRM,
                                    'Fallo al insertar los datos');
  END P_CPU_MEM_DEVICE_AVG_DAY;
  --**--**--**--
END G_CISCO_PRIME;
/
