--------------------------------------------------------
--  DDL for Table CSCO_CPU_MEM_DEVICE_AVG_DAY
--------------------------------------------------------

  CREATE TABLE CSCO_CPU_MEM_DEVICE_AVG_DAY 
   (	FECHA DATE, 
	NODE VARCHAR2(255 CHAR), 
	CPUUTILMAX5MINDEVICEAVG NUMBER(15,2), 
	CPUUTILAVG5MINDEVICEAVG NUMBER(15,2), 
	CPUUTILMAX1MINDEVICEAVG NUMBER(15,2), 
	CPUUTILAVG1MINDEVICEAVG NUMBER(15,2), 
	USEDBYTESDEVICEAVG NUMBER, 
	FREEBYTESDEVICEAVG NUMBER, 
	AVGUTILDEVICEAVG NUMBER, 
	MAXUTILDEVICEAVG NUMBER
   )  NOCOMPRESS NOLOGGING
  PARTITION BY RANGE (FECHA)
  (
  PARTITION CPUMEMDEVICEAVGDAY201610 VALUES LESS THAN (TO_DATE('01.11.2016','DD.MM.YYYY')) TABLESPACE TBS_DAY PCTFREE 10 PCTUSED 80,
  PARTITION CPUMEMDEVICEAVGDAY201611 VALUES LESS THAN (TO_DATE('01.12.2016','DD.MM.YYYY')) TABLESPACE TBS_DAY PCTFREE 10 PCTUSED 80,
  PARTITION CPUMEMDEVICEAVGDAY201612 VALUES LESS THAN (TO_DATE('01.01.2017','DD.MM.YYYY')) TABLESPACE TBS_DAY PCTFREE 10 PCTUSED 80
  )
  TABLESPACE TBS_DAY ;

   COMMENT ON COLUMN CSCO_CPU_MEM_DEVICE_AVG_DAY.FECHA IS 'Reemplazo de la columna TIMESTAMP por ser palabra reservada';
   COMMENT ON TABLE CSCO_CPU_MEM_DEVICE_AVG_DAY  IS 'Contiene los datos de la union de las tablas CSCO_CPU_DEVICE_AVG y CSCO_MEMORY_DEVICE_AVG unidos por FECHA, NODE';
--------------------------------------------------------
--  DDL for Index PK_CSCO_CPU_MEM_DEVICE_AVG_D
--------------------------------------------------------

  CREATE UNIQUE INDEX PK_CSCO_CPU_MEM_DEVICE_AVG_D ON CSCO_CPU_MEM_DEVICE_AVG_DAY (FECHA, NODE) LOCAL
  TABLESPACE TBS_DAY ;
--------------------------------------------------------
--  Constraints for Table CSCO_CPU_MEM_DEVICE_AVG_DAY
--------------------------------------------------------

  ALTER TABLE CSCO_CPU_MEM_DEVICE_AVG_DAY ADD CONSTRAINT PK_CSCO_CPU_MEM_DEVICE_AVG_D PRIMARY KEY (FECHA, NODE)  ENABLE;
  ALTER TABLE CSCO_CPU_MEM_DEVICE_AVG_DAY MODIFY (MAXUTILDEVICEAVG NOT NULL ENABLE);
  ALTER TABLE CSCO_CPU_MEM_DEVICE_AVG_DAY MODIFY (AVGUTILDEVICEAVG NOT NULL ENABLE);
  ALTER TABLE CSCO_CPU_MEM_DEVICE_AVG_DAY MODIFY (FREEBYTESDEVICEAVG NOT NULL ENABLE);
  ALTER TABLE CSCO_CPU_MEM_DEVICE_AVG_DAY MODIFY (USEDBYTESDEVICEAVG NOT NULL ENABLE);
  ALTER TABLE CSCO_CPU_MEM_DEVICE_AVG_DAY MODIFY (CPUUTILAVG1MINDEVICEAVG NOT NULL ENABLE);
  ALTER TABLE CSCO_CPU_MEM_DEVICE_AVG_DAY MODIFY (CPUUTILMAX1MINDEVICEAVG NOT NULL ENABLE);
  ALTER TABLE CSCO_CPU_MEM_DEVICE_AVG_DAY MODIFY (CPUUTILAVG5MINDEVICEAVG NOT NULL ENABLE);
  ALTER TABLE CSCO_CPU_MEM_DEVICE_AVG_DAY MODIFY (CPUUTILMAX5MINDEVICEAVG NOT NULL ENABLE);
  ALTER TABLE CSCO_CPU_MEM_DEVICE_AVG_DAY MODIFY (NODE NOT NULL ENABLE);
  ALTER TABLE CSCO_CPU_MEM_DEVICE_AVG_DAY MODIFY (FECHA NOT NULL ENABLE);