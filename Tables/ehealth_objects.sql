
CREATE TABLE EHEALTH_OBJECTS(
  ELEMENT_ID        NUMBER NOT NULL PRIMARY KEY
, ELEMENT_ALIASES   VARCHAR2(500 CHAR) 
, VALID_START_DATE  DATE 
, VALID_FINISH_DATE DATE 
, TIPO              VARCHAR2(40 CHAR) 
, ORIGEN            VARCHAR2(40 CHAR) 
, DESTINO           VARCHAR2(40 CHAR) 
, FLAG_ENABLED      CHAR(1 CHAR) 
, GRUPO             VARCHAR2(50 CHAR) 
, PAIS              VARCHAR2(20 CHAR) 
, ELEMENT_TYPE      VARCHAR2(20 CHAR) 
, ELEMENT_NAME      VARCHAR2(20 CHAR) 
, INTERFACE_NAME    VARCHAR2(100 CHAR) 
, GROUP_TYPE        VARCHAR2(20 CHAR) 
, ELEMENT_IP        VARCHAR2(15 CHAR) 
, NOMBRE_GRUPO      VARCHAR2(50 CHAR) 
, FRONTERA          VARCHAR2(30 CHAR) 
, SPEED_MODIFY      NUMBER
) NOLOGGING;