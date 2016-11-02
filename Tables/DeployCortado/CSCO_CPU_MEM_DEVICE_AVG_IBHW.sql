--------------------------------------------------------
--  DDL for Table CSCO_CPU_MEM_DEVICE_AVG_IBHW
--------------------------------------------------------

  CREATE TABLE CSCO_CPU_MEM_DEVICE_AVG_IBHW 
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
  TABLESPACE TBS_SUMMARY ;

   COMMENT ON COLUMN CSCO_CPU_MEM_DEVICE_AVG_IBHW.FECHA IS 'Reemplazo de la columna TIMESTAMP por ser palabra reservada';
   COMMENT ON TABLE CSCO_CPU_MEM_DEVICE_AVG_IBHW  IS 'Contiene los datos de la union de las tablas CSCO_CPU_DEVICE_AVG y CSCO_MEMORY_DEVICE_AVG unidos por FECHA, NODE';
--------------------------------------------------------
--  DDL for Index PK_CSCO_CPU_MEM_DEVICE_AVG_IB
--------------------------------------------------------

  CREATE UNIQUE INDEX PK_CSCO_CPU_MEM_DEVICE_AVG_IB ON CSCO_CPU_MEM_DEVICE_AVG_IBHW (FECHA, NODE) 
  TABLESPACE TBS_SUMMARY ;
--------------------------------------------------------
--  Constraints for Table CSCO_CPU_MEM_DEVICE_AVG_IBHW
--------------------------------------------------------

  ALTER TABLE CSCO_CPU_MEM_DEVICE_AVG_IBHW ADD CONSTRAINT PK_CSCO_CPU_MEM_DEVICE_AVG_IB PRIMARY KEY (FECHA, NODE)  ENABLE;
  ALTER TABLE CSCO_CPU_MEM_DEVICE_AVG_IBHW MODIFY (MAXUTILDEVICEAVG NOT NULL ENABLE);
  ALTER TABLE CSCO_CPU_MEM_DEVICE_AVG_IBHW MODIFY (AVGUTILDEVICEAVG NOT NULL ENABLE);
  ALTER TABLE CSCO_CPU_MEM_DEVICE_AVG_IBHW MODIFY (FREEBYTESDEVICEAVG NOT NULL ENABLE);
  ALTER TABLE CSCO_CPU_MEM_DEVICE_AVG_IBHW MODIFY (USEDBYTESDEVICEAVG NOT NULL ENABLE);
  ALTER TABLE CSCO_CPU_MEM_DEVICE_AVG_IBHW MODIFY (CPUUTILAVG1MINDEVICEAVG NOT NULL ENABLE);
  ALTER TABLE CSCO_CPU_MEM_DEVICE_AVG_IBHW MODIFY (CPUUTILMAX1MINDEVICEAVG NOT NULL ENABLE);
  ALTER TABLE CSCO_CPU_MEM_DEVICE_AVG_IBHW MODIFY (CPUUTILAVG5MINDEVICEAVG NOT NULL ENABLE);
  ALTER TABLE CSCO_CPU_MEM_DEVICE_AVG_IBHW MODIFY (CPUUTILMAX5MINDEVICEAVG NOT NULL ENABLE);
  ALTER TABLE CSCO_CPU_MEM_DEVICE_AVG_IBHW MODIFY (NODE NOT NULL ENABLE);
  ALTER TABLE CSCO_CPU_MEM_DEVICE_AVG_IBHW MODIFY (FECHA NOT NULL ENABLE);