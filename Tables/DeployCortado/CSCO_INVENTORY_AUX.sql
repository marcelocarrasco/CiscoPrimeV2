--------------------------------------------------------
--  DDL for Table CSCO_INVENTORY_AUX
--------------------------------------------------------

  CREATE TABLE CSCO_INVENTORY_AUX 
   (	ROWNUMBER NUMBER, 
	LINEA VARCHAR2(4000 CHAR), 
	VALOR VARCHAR2(4000 CHAR)
   ) NOCOMPRESS NOLOGGING
  TABLESPACE TBS_AUXILIAR ;
--------------------------------------------------------
--  Constraints for Table CSCO_INVENTORY_AUX
--------------------------------------------------------

  ALTER TABLE CSCO_INVENTORY_AUX MODIFY (VALOR NOT NULL ENABLE);
  ALTER TABLE CSCO_INVENTORY_AUX MODIFY (LINEA NOT NULL ENABLE);
  ALTER TABLE CSCO_INVENTORY_AUX MODIFY (ROWNUMBER NOT NULL ENABLE);
