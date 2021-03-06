--------------------------------------------------------
--  DDL for Table CSCO_MEMORY_DEVICE_AVG_HOUR
--------------------------------------------------------

  CREATE TABLE CSCO_MEMORY_DEVICE_AVG_HOUR 
   (	FECHA DATE, 
	NODE VARCHAR2(255 CHAR), 
	USEDBYTESDEVICEAVG NUMBER, 
	FREEBYTESDEVICEAVG NUMBER, 
	AVGUTILDEVICEAVG NUMBER, 
	MAXUTILDEVICEAVG NUMBER
   ) NOCOMPRESS NOLOGGING
   PARTITION BY RANGE (FECHA)
   (
    PARTITION MEMORYDEVICEAVGHOUR201610 VALUES LESS THAN (TO_DATE('2016.11.01','YYYY.MM.DD')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION MEMORYDEVICEAVGHOUR201611 VALUES LESS THAN (TO_DATE('2016.12.01','YYYY.MM.DD')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION MEMORYDEVICEAVGHOUR201612 VALUES LESS THAN (TO_DATE('2017.01.01','YYYY.MM.DD')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80
   )
  TABLESPACE TBS_HOUR ;

   COMMENT ON COLUMN CSCO_MEMORY_DEVICE_AVG_HOUR.FECHA IS 'Reemplazo de la columna TIMESTAMP por ser palabra reservada';
--------------------------------------------------------
--  DDL for Index IDX_MEM_DEVICE_AVG_HOUR_FECHA
--------------------------------------------------------

  CREATE INDEX IDX_MEM_DEVICE_AVG_HOUR_FECHA ON CSCO_MEMORY_DEVICE_AVG_HOUR (TO_CHAR(FECHA,'DD.MM.YYYY')) LOCAL
  TABLESPACE TBS_HOUR ;
--------------------------------------------------------
--  DDL for Index CSCO_MEMORY_DEVICE_AVG_HOU_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX CSCO_MEMORY_DEVICE_AVG_HOU_PK ON CSCO_MEMORY_DEVICE_AVG_HOUR (FECHA, NODE) LOCAL
  TABLESPACE TBS_HOUR ;
--------------------------------------------------------
--  Constraints for Table CSCO_MEMORY_DEVICE_AVG_HOUR
--------------------------------------------------------

  ALTER TABLE CSCO_MEMORY_DEVICE_AVG_HOUR MODIFY (MAXUTILDEVICEAVG NOT NULL ENABLE);
  ALTER TABLE CSCO_MEMORY_DEVICE_AVG_HOUR MODIFY (AVGUTILDEVICEAVG NOT NULL ENABLE);
  ALTER TABLE CSCO_MEMORY_DEVICE_AVG_HOUR MODIFY (FREEBYTESDEVICEAVG NOT NULL ENABLE);
  ALTER TABLE CSCO_MEMORY_DEVICE_AVG_HOUR MODIFY (USEDBYTESDEVICEAVG NOT NULL ENABLE);
  ALTER TABLE CSCO_MEMORY_DEVICE_AVG_HOUR MODIFY (NODE NOT NULL ENABLE);
  ALTER TABLE CSCO_MEMORY_DEVICE_AVG_HOUR MODIFY (FECHA NOT NULL ENABLE);
  ALTER TABLE CSCO_MEMORY_DEVICE_AVG_HOUR ADD CONSTRAINT CSCO_MEMORY_DEVICE_AVG_HOU_PK PRIMARY KEY (FECHA, NODE)  ENABLE;
