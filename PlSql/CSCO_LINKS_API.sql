desc user_tab_columns
SET FEEDBACK OFF
SET HEAD OFF

select column_name||','
from user_tab_columns
where table_name = 'CSCO_LINKS'
order by COLUMN_ID;

select ''''||COLUMN_NAME||' => '''||CHR(124)||CHR(124)||'P_LINKS_DATA(indice).'||column_name||CHR(124)||CHR(124)
from user_tab_columns
where table_name = 'CSCO_LINKS'
order by COLUMN_ID;

select column_name||'= CSCO_LINKS_tapi_tab(indice).'||column_name||','
from user_tab_columns
where table_name = 'CSCO_LINKS'
order by COLUMN_ID;

SELECT ASCII('|') FROM DUAL;
 



-- drop type CSCO_LINKS_tapi_rec;
create type CSCO_LINKS_TAPI_REC as object
  (
    ELEMENT_ID        NUMBER,
    ELEMENT_ALIASES   VARCHAR2(500 CHAR),
    VALID_START_DATE	DATE,
    VALID_FINISH_DATE	DATE,
    TIPO	            VARCHAR2(40 CHAR),
    ORIGEN	          VARCHAR2(40 CHAR),
    DESTINO	          VARCHAR2(40 CHAR),
    FLAG_ENABLED	    CHAR(1 CHAR),
    GRUPO	            VARCHAR2(50 CHAR),
    PAIS	            VARCHAR2(20 CHAR),
    ELEMENT_TYPE	    VARCHAR2(20 CHAR),
    ELEMENT_NAME	    VARCHAR2(20 CHAR),
    INTERFACE_NAME	  VARCHAR2(100 CHAR),
    GROUP_TYPE	      VARCHAR2(20 CHAR),
    ELEMENT_IP	      VARCHAR2(15 CHAR),
    NOMBRE_GRUPO	    VARCHAR2(50 CHAR),
    FRONTERA	        VARCHAR2(30 CHAR),
    SPEED_MODIFY	    NUMBER
);

-- drop type CSCO_LINKS_tapi_tab;
create type CSCO_LINKS_TAPI_TAB IS TABLE OF CSCO_LINKS_TAPI_REC;


CREATE OR REPLACE PACKAGE CSCO_LINKS_TAPI
IS
  -- insert
  PROCEDURE P_CSCO_LINKS_INS(P_LINKS_DATA IN CSCO_LINKS_TAPI_TAB, P_ERROR OUT NUMBER);
  
END CSCO_LINKS_TAPI;

CREATE OR REPLACE PACKAGE body CSCO_LINKS_TAPI
IS
  -- insert
  PROCEDURE P_CSCO_LINKS_INS(P_LINKS_DATA IN CSCO_LINKS_TAPI_TAB,P_ERROR OUT NUMBER)
  IS
  BEGIN
    EXECUTE IMMEDIATE 'alter session set nls_date_format = ''DD.MM.YYYY HH24:MI:SS''';
    FORALL indice IN INDICES OF P_LINKS_DATA
      MERGE INTO CSCO_LINKS CL
      USING DUAL
      ON (CL.ELEMENT_ALIASES = P_LINKS_DATA(indice).ELEMENT_ALIASES AND CL.ELEMENT_ID = P_LINKS_DATA(indice).ELEMENT_ID)
      WHEN MATCHED THEN
        UPDATE SET 
          --ELEMENT_ID= CSCO_LINKS_tapi_tab(indice).ELEMENT_ID,
          --ELEMENT_ALIASES   = P_LINKS_DATA(indice).ELEMENT_ALIASES,
          VALID_START_DATE  = P_LINKS_DATA(indice).VALID_START_DATE,                 
          VALID_FINISH_DATE = P_LINKS_DATA(indice).VALID_FINISH_DATE,               
          TIPO              = P_LINKS_DATA(indice).TIPO,            
          ORIGEN            = P_LINKS_DATA(indice).ORIGEN,        
          DESTINO           = P_LINKS_DATA(indice).DESTINO,      
          FLAG_ENABLED      = P_LINKS_DATA(indice).FLAG_ENABLED,      
          GRUPO             = P_LINKS_DATA(indice).GRUPO,          
          PAIS              = P_LINKS_DATA(indice).PAIS,            
          ELEMENT_TYPE      = P_LINKS_DATA(indice).ELEMENT_TYPE,
          ELEMENT_NAME      = P_LINKS_DATA(indice).ELEMENT_NAME,      
          INTERFACE_NAME    = P_LINKS_DATA(indice).INTERFACE_NAME,  
          GROUP_TYPE        = P_LINKS_DATA(indice).GROUP_TYPE,
          ELEMENT_IP        = P_LINKS_DATA(indice).ELEMENT_IP,
          NOMBRE_GRUPO      = P_LINKS_DATA(indice).NOMBRE_GRUPO,      
          FRONTERA          = P_LINKS_DATA(indice).FRONTERA,    
          SPEED_MODIFY      = P_LINKS_DATA(indice).SPEED_MODIFY
      WHEN NOT MATCHED THEN
        INSERT (ELEMENT_ID,ELEMENT_ALIASES,VALID_START_DATE,VALID_FINISH_DATE,TIPO,ORIGEN,DESTINO,FLAG_ENABLED,GRUPO,
                PAIS,ELEMENT_TYPE,ELEMENT_NAME,INTERFACE_NAME,GROUP_TYPE,ELEMENT_IP,NOMBRE_GRUPO,FRONTERA,SPEED_MODIFY)
        VALUES (P_LINKS_DATA(indice).ELEMENT_ID,P_LINKS_DATA(indice).ELEMENT_ALIASES,P_LINKS_DATA(indice).VALID_START_DATE,
                P_LINKS_DATA(indice).VALID_FINISH_DATE,P_LINKS_DATA(indice).TIPO,P_LINKS_DATA(indice).ORIGEN,    
                P_LINKS_DATA(indice).DESTINO,P_LINKS_DATA(indice).FLAG_ENABLED,P_LINKS_DATA(indice).GRUPO,     
                P_LINKS_DATA(indice).PAIS,P_LINKS_DATA(indice).ELEMENT_TYPE,P_LINKS_DATA(indice).ELEMENT_NAME,   
                P_LINKS_DATA(indice).INTERFACE_NAME,P_LINKS_DATA(indice).GROUP_TYPE,P_LINKS_DATA(indice).ELEMENT_IP,
                P_LINKS_DATA(indice).NOMBRE_GRUPO,P_LINKS_DATA(indice).FRONTERA,P_LINKS_DATA(indice).SPEED_MODIFY
                );
      --
      EXCEPTION
          WHEN OTHERS THEN
            L_ERRORS := SQL%BULK_EXCEPTIONS.COUNT;
            FOR indice IN 1 .. L_ERRORS
            LOOP
              L_ERRNO := SQL%BULK_EXCEPTIONS(indice).ERROR_CODE;
              L_MSG   := SQLERRM(-L_ERRNO);
              L_IDX   := SQL%BULK_EXCEPTIONS(indice).ERROR_INDEX;
              g_error_log_new.P_LOG_ERROR('P_CSCO_LINKS_INS',
                                          L_ERRNO,
                                          L_MSG,
                                          'ELEMENT_ID => '        ||TO_CHAR(P_LINKS_DATA(indice).ELEMENT_ID)||                             
                                          'ELEMENT_ALIASES => '   ||P_LINKS_DATA(indice).ELEMENT_ALIASES||                   
                                          'VALID_START_DATE => '  ||P_LINKS_DATA(indice).VALID_START_DATE||                 
                                          'VALID_FINISH_DATE => ' ||P_LINKS_DATA(indice).VALID_FINISH_DATE||               
                                          'TIPO => '              ||P_LINKS_DATA(indice).TIPO||                                         
                                          'ORIGEN => '            ||P_LINKS_DATA(indice).ORIGEN||                                     
                                          'DESTINO => '           ||P_LINKS_DATA(indice).DESTINO||                                   
                                          'FLAG_ENABLED => '      ||P_LINKS_DATA(indice).FLAG_ENABLED||                         
                                          'GRUPO => '             ||P_LINKS_DATA(indice).GRUPO||                                       
                                          'PAIS => '              ||P_LINKS_DATA(indice).PAIS||                                         
                                          'ELEMENT_TYPE => '      ||P_LINKS_DATA(indice).ELEMENT_TYPE||                         
                                          'ELEMENT_NAME => '      ||P_LINKS_DATA(indice).ELEMENT_NAME||                         
                                          'INTERFACE_NAME => '    ||P_LINKS_DATA(indice).INTERFACE_NAME||                     
                                          'GROUP_TYPE => '        ||P_LINKS_DATA(indice).GROUP_TYPE||                             
                                          'ELEMENT_IP => '        ||P_LINKS_DATA(indice).ELEMENT_IP||                             
                                          'NOMBRE_GRUPO => '      ||P_LINKS_DATA(indice).NOMBRE_GRUPO||                         
                                          'FRONTERA => '          ||P_LINKS_DATA(indice).FRONTERA||                                 
                                          'SPEED_MODIFY => '      ||TO_CHAR(P_LINKS_DATA(indice).SPEED_MODIFY));
              P_ERROR := 1;
            END LOOP;
  COMMIT;
  END P_CSCO_LINKS_INS;
END CSCO_LINKS_TAPI;

GRANT EXECUTE ON CSCO_LINKS_TAPI TO PRFC;



SET SERVEROUTPUT ON
DECLARE
CSCO_LINKS_D CSCO_LINKS_TAPI_TAB;
V_ERROR NUMBER := -1;
BEGIN
CSCO_LINKS_D := CSCO_LINKS_TAPI_TAB(CSCO_LINKS_TAPI_REC(4500000,'marcelo_test6','04.05.2012 15:49:06','04.05.2012 15:49:06','Cable','HFC','HFC','S','HFC','Argentina','HFC-Cisco','nave01cm01','Cable7-0-0-up0','HFC_UPSTREAM','1.1.1.1',NULL,NULL,NULL),
CSCO_LINKS_TAPI_REC(4500001,'marcelo_test2','21.05.2012 15:49:06','04.05.2012 15:49:06','Cable','HFC','HFC','S','HFC','Argentina','HFC-Cisco','nave01cm01','Cable7-0-0-up0','HFC_UPSTREAM','1.1.1.1',NULL,NULL,NULL),
CSCO_LINKS_TAPI_REC(4500002,'marcelo_test3','21.05.2012 15:49:06','04.05.2012 15:49:06','Cable','HFC','HFC','N','HFC','Argentina','HFC-Cisco','nave01cm01','Cable7-0-0-up0','HFC_UPSTREAM','1.1.1.1',NULL,NULL,NULL),
CSCO_LINKS_TAPI_REC(4500003,'marcelo_test4','21.05.2012 15:49:06','04.05.2012 15:49:06','Cable','HFC','HFC','S','HFC','Argentina','HFC-Cisco','nave01cm01','Cable7-0-0-up0','HFC_UPSTREAM','1.1.1.1',NULL,NULL,NULL),
CSCO_LINKS_TAPI_REC(4500003,'marcelo_test5','21.05.2012 15:49:06','04.05.2012 15:49:06','Cable','HFC','HFC','S','HFC','Argentina','HFC-Cisco','nave01cm01','Cable7-0-0-up0','HFC_UPSTREAM','1.1.1.1',NULL,NULL,NULL));

CSCO_LINKS_TAPI.P_CSCO_LINKS_INS(CSCO_LINKS_D,V_ERROR);
DBMS_OUTPUT.PUT_LINE(TO_CHAR(V_ERROR));

END;



