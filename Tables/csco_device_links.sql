
-- DROP TABLE CSCO_DEVICE_LINKS_AUX

CREATE TABLE CSCO_DEVICE_LINKS_AUX(
LINEA       VARCHAR2(4000 CHAR) NOT NULL ENABLE, 
AENDPOINT   VARCHAR2(4000 CHAR) GENERATED ALWAYS AS (substr(REGEXP_SUBSTR(linea,'(Key=[^)]*)',1,1),5)) VIRTUAL,
PORTNUMBERA VARCHAR2(4000 CHAR) GENERATED ALWAYS AS (substr(REGEXP_SUBSTR(linea, '(PortNumber=[A-Z a-z]*[0-9]*[/ 0-9]*)',1,1),12)) VIRTUAL,
LINKTYPE 	  VARCHAR2(4000 CHAR) GENERATED ALWAYS AS (substr(REGEXP_SUBSTR(LINEA,'(LinkType=[^)]*)',1,1),10)) VIRTUAL,
ZENDPOINT   VARCHAR2(4000 CHAR) GENERATED ALWAYS AS (substr(REGEXP_SUBSTR(linea,'(Key=[^)]*)',1,2),5)) VIRTUAL,
PORTNUMBERZ VARCHAR2(4000 CHAR) GENERATED ALWAYS AS (substr(REGEXP_SUBSTR(linea,'(PortNumber=[A-Z a-z]*[0-9]*[/ 0-9]*)',1,2),12)) VIRTUAL,
ROWNUMBER   NUMBER
 ) nologging;

COMMENT ON COLUMN CSCO_DEVICE_LINKS_AUX.LINEA IS 'Linea original del archivo';
COMMENT ON COLUMN CSCO_DEVICE_LINKS_AUX.AENDPOINT IS 'Linea armada a partir de la que viene en el archivo';
COMMENT ON COLUMN CSCO_DEVICE_LINKS_AUX.ZENDPOINT IS 'Linea armada a partir de la que viene en el archivo';
COMMENT ON COLUMN CSCO_DEVICE_LINKS_AUX.ROWNUMBER IS 'Corresponde al numero de fila en la que se ubica en el archivo de origen';
COMMENT ON COLUMN CSCO_DEVICE_LINKS_AUX.PORTNUMBERA IS 'Interface de salida del equipo origen AEndPoint';
COMMENT ON COLUMN CSCO_DEVICE_LINKS_AUX.PORTNUMBERZ IS 'Interface de llegada al equipo destino ZEndPoint';

-- DROP TABLE CSCO_DEVICE_LINKS

create table CSCO_DEVICE_LINKS(
CONTEXTO	    VARCHAR2(255 CHAR),
SEVERITY	    VARCHAR2(255 CHAR),
AENDPOINT	    VARCHAR2(255 CHAR) NOT NULL,
PORTNUMBERA   VARCHAR2(255 CHAR) NOT NULL,
BIDIRECTIONAL	CHAR(2),
ZENDPOINT	    VARCHAR2(255 CHAR) NOT NULL,
PORTNUMBERZ   VARCHAR2(255 CHAR) NOT NULL,
LINKTYPE 	    CHAR(2),
ROWNUMBER     NUMBER NOT NULL,
ELEMENT_ALIASES VARCHAR2(2040 CHAR) GENERATED ALWAYS AS (AENDPOINT||'_'||PORTNUMBERA||'_to_'||
                                                        ZENDPOINT||'_'||PORTNUMBERZ) VIRTUAL
) nologging;

COMMENT ON COLUMN CSCO_DEVICE_LINKS.CONTEXTO IS 'Reescritura de la columna CONTEXT por ser palabra reservada';
COMMENT ON COLUMN CSCO_DEVICE_LINKS.AENDPOINT IS 'Reescritura de la columna A End-Point';
COMMENT ON COLUMN CSCO_DEVICE_LINKS.ZENDPOINT IS 'Reescritura de la columna Z End-Point';
COMMENT ON COLUMN CSCO_DEVICE_LINKS.LINKTYPE IS 'Reescritura de la columna Link Type';
COMMENT ON COLUMN CSCO_DEVICE_LINKS.BIDIRECTIONAL IS 'Reescritura de la columna BI DIRECTIONAL';
COMMENT ON COLUMN CSCO_DEVIVE_LINKS.ROWNUMBER IS 'Corresponde al numero de fila en la que se ubica en el archivo de origen';
COMMENT ON COLUMN CSCO_DEVICE_LINKS.PORTNUMBERA IS 'Interface de salida del equipo origen AEndPoint';
COMMENT ON COLUMN CSCO_DEVICE_LINKS.PORTNUMBERZ IS 'Interface de llegada al equipo destino ZEndPoint';
--
-- drop table CSCO_INVENTORY_AUX;

create table CSCO_INVENTORY_AUX(
ROWNUMBER      NUMBER NOT NULL,
LINEA         VARCHAR2(4000 CHAR) NOT NULL,
VALOR         VARCHAR2(4000 CHAR) NOT NULL) nologging;
/*,
DEVICE	      VARCHAR2(4000 CHAR) GENERATED ALWAYS AS (substr(REGEXP_SUBSTR(LINEA,'(key=DeviceName, value=[^)]*)',1,1),23)) VIRTUAL,
DEVICE_SERIES	VARCHAR2(4000 CHAR) GENERATED ALWAYS AS (substr(REGEXP_SUBSTR(LINEA,'(key=DeviceSerialNumber, value=[^)]*)',1,1),31)) VIRTUAL,
ELEMENT_TYPE	VARCHAR2(4000 CHAR) GENERATED ALWAYS AS (substr(REGEXP_SUBSTR(LINEA,'(key=ElementType, value=[^)]*)',1,1),24)) VIRTUAL,
IP_ADDRESS	  VARCHAR2(4000 CHAR) GENERATED ALWAYS AS (substr(REGEXP_SUBSTR(LINEA,'(key=IP, value=[^)]*)',1,1),15)) VIRTUAL*/


-- drop table CSCO_INVENTORY

create table CSCO_INVENTORY(
INVENTORY_ID  VARCHAR2(32 CHAR)   NOT NULL,
DEVICE	      VARCHAR2(255 CHAR)  NOT NULL,
DEVICE_SERIES	VARCHAR2(255 CHAR)  NOT NULL,
ELEMENT_TYPE	VARCHAR2(255 CHAR)  NOT NULL,
IP_ADDRESS	  VARCHAR2(255 CHAR)  NOT NULL
) nologging;


COMMENT ON COLUMN CSCO_INVENTORY.IP_ADDRESS IS 'Reescritura de la columna IP ADDRESS por ser palabra reservada';
COMMENT ON COLUMN CSCO_INVENTORY.DEVICE_SERIES IS 'Reescritura de la columna DEVICE SERIES';
COMMENT ON COLUMN CSCO_INVENTORY.ELEMENT_TYPE IS 'Reescritura de la columna ELEMENT TYPE';
COMMENT ON COLUMN CSCO_INVENTORY.INVENTORY_ID IS 'STANDARD_HASH(MD5) aplicado a la columna device para ser utilizado como PK';

ALTER TABLE CSCO_INVENTORY ADD CONSTRAINT PK_CSCO_INVENTORY PRIMARY KEY (INVENTORY_ID);




