--------------------------------------------------------
--  DDL for Table CSCO_DEVICE_LINKS_AUX
--------------------------------------------------------

  CREATE TABLE CSCO_DEVICE_LINKS_AUX 
   (	LINEA VARCHAR2(4000 CHAR), 
	AENDPOINT VARCHAR2(4000 CHAR) GENERATED ALWAYS AS (SUBSTR( REGEXP_SUBSTR (LINEA,'(Key=[^)]*)',1,1),5)) VIRTUAL , 
	PORTNUMBERA VARCHAR2(4000 CHAR) GENERATED ALWAYS AS (SUBSTR( REGEXP_SUBSTR (LINEA,'(PortNumber=[A-Z a-z]*[0-9]*[/ 0-9]*)',1,1),12)) VIRTUAL , 
	LINKTYPE VARCHAR2(4000 CHAR) GENERATED ALWAYS AS (SUBSTR( REGEXP_SUBSTR (LINEA,'(LinkType=[^)]*)',1,1),10)) VIRTUAL , 
	ZENDPOINT VARCHAR2(4000 CHAR) GENERATED ALWAYS AS (SUBSTR( REGEXP_SUBSTR (LINEA,'(Key=[^)]*)',1,2),5)) VIRTUAL , 
	PORTNUMBERZ VARCHAR2(4000 CHAR) GENERATED ALWAYS AS (SUBSTR( REGEXP_SUBSTR (LINEA,'(PortNumber=[A-Z a-z]*[0-9]*[/ 0-9]*)',1,2),12)) VIRTUAL , 
	ROWNUMBER NUMBER
   )  NOCOMPRESS NOLOGGING
  TABLESPACE TBS_AUXILIAR ;

   COMMENT ON COLUMN CSCO_DEVICE_LINKS_AUX.LINEA IS 'Linea original del archivo';
   COMMENT ON COLUMN CSCO_DEVICE_LINKS_AUX.AENDPOINT IS 'Linea armada a partir de la que viene en el archivo';
   COMMENT ON COLUMN CSCO_DEVICE_LINKS_AUX.PORTNUMBERA IS 'Interface de salida del equipo origen AEndPoint';
   COMMENT ON COLUMN CSCO_DEVICE_LINKS_AUX.ZENDPOINT IS 'Linea armada a partir de la que viene en el archivo';
   COMMENT ON COLUMN CSCO_DEVICE_LINKS_AUX.PORTNUMBERZ IS 'Interface de llegada al equipo destino ZEndPoint';
   COMMENT ON COLUMN CSCO_DEVICE_LINKS_AUX.ROWNUMBER IS 'Corresponde al numero de fila en la que se ubica en el archivo de origen';
--------------------------------------------------------
--  Constraints for Table CSCO_DEVICE_LINKS_AUX
--------------------------------------------------------

  ALTER TABLE CSCO_DEVICE_LINKS_AUX MODIFY (LINEA NOT NULL ENABLE);
