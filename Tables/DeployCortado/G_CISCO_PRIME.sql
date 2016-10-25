--------------------------------------------------------
--  DDL for Package G_CISCO_PRIME
--------------------------------------------------------

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
