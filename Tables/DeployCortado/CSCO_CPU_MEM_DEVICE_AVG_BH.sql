--------------------------------------------------------
--  DDL for Table CSCO_CPU_MEM_DEVICE_AVG_BH
--------------------------------------------------------

  CREATE TABLE CSCO_CPU_MEM_DEVICE_AVG_BH 
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
    PARTITION CPUMEMDEVICEAVGBH201607 VALUES LESS THAN (TO_DATE('01.08.2016','DD.MM.YYYY')) TABLESPACE TBS_DAY PCTFREE 10 PCTUSED 80,
    PARTITION CPUMEMDEVICEAVGBH201608 VALUES LESS THAN (TO_DATE('01.09.2016','DD.MM.YYYY')) TABLESPACE TBS_DAY PCTFREE 10 PCTUSED 80,
    PARTITION CPUMEMDEVICEAVGBH201609 VALUES LESS THAN (TO_DATE('01.10.2016','DD.MM.YYYY')) TABLESPACE TBS_DAY PCTFREE 10 PCTUSED 80,
    PARTITION CPUMEMDEVICEAVGBH201610 VALUES LESS THAN (TO_DATE('01.11.2016','DD.MM.YYYY')) TABLESPACE TBS_DAY PCTFREE 10 PCTUSED 80,
    PARTITION CPUMEMDEVICEAVGBH201611 VALUES LESS THAN (TO_DATE('01.12.2016','DD.MM.YYYY')) TABLESPACE TBS_DAY PCTFREE 10 PCTUSED 80,
    PARTITION CPUMEMDEVICEAVGBH201612 VALUES LESS THAN (TO_DATE('01.01.2017','DD.MM.YYYY')) TABLESPACE TBS_DAY PCTFREE 10 PCTUSED 80
   )
  TABLESPACE TBS_DAY ;

   COMMENT ON COLUMN CSCO_CPU_MEM_DEVICE_AVG_BH.FECHA IS 'Reemplazo de la columna TIMESTAMP por ser palabra reservada';
   COMMENT ON TABLE CSCO_CPU_MEM_DEVICE_AVG_BH  IS 'Contiene los datos de la union de las tablas CSCO_CPU_DEVICE_AVG y CSCO_MEMORY_DEVICE_AVG unidos por FECHA, NODE';
--------------------------------------------------------
--  DDL for Index PK_CSCO_CPU_MEM_DEVICE_AVG_BH
--------------------------------------------------------

  CREATE UNIQUE INDEX PK_CSCO_CPU_MEM_DEVICE_AVG_BH ON CSCO_CPU_MEM_DEVICE_AVG_BH (FECHA, NODE) LOCAL
  TABLESPACE TBS_DAY ;
--------------------------------------------------------
--  Constraints for Table CSCO_CPU_MEM_DEVICE_AVG_BH
--------------------------------------------------------

  ALTER TABLE CSCO_CPU_MEM_DEVICE_AVG_BH ADD CONSTRAINT PK_CSCO_CPU_MEM_DEVICE_AVG_BH PRIMARY KEY (FECHA, NODE)  ENABLE;
  ALTER TABLE CSCO_CPU_MEM_DEVICE_AVG_BH MODIFY (MAXUTILDEVICEAVG NOT NULL ENABLE);
  ALTER TABLE CSCO_CPU_MEM_DEVICE_AVG_BH MODIFY (AVGUTILDEVICEAVG NOT NULL ENABLE);
  ALTER TABLE CSCO_CPU_MEM_DEVICE_AVG_BH MODIFY (FREEBYTESDEVICEAVG NOT NULL ENABLE);
  ALTER TABLE CSCO_CPU_MEM_DEVICE_AVG_BH MODIFY (USEDBYTESDEVICEAVG NOT NULL ENABLE);
  ALTER TABLE CSCO_CPU_MEM_DEVICE_AVG_BH MODIFY (CPUUTILAVG1MINDEVICEAVG NOT NULL ENABLE);
  ALTER TABLE CSCO_CPU_MEM_DEVICE_AVG_BH MODIFY (CPUUTILMAX1MINDEVICEAVG NOT NULL ENABLE);
  ALTER TABLE CSCO_CPU_MEM_DEVICE_AVG_BH MODIFY (CPUUTILAVG5MINDEVICEAVG NOT NULL ENABLE);
  ALTER TABLE CSCO_CPU_MEM_DEVICE_AVG_BH MODIFY (CPUUTILMAX5MINDEVICEAVG NOT NULL ENABLE);
  ALTER TABLE CSCO_CPU_MEM_DEVICE_AVG_BH MODIFY (NODE NOT NULL ENABLE);
  ALTER TABLE CSCO_CPU_MEM_DEVICE_AVG_BH MODIFY (FECHA NOT NULL ENABLE);
