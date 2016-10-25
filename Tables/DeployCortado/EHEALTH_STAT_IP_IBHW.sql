--------------------------------------------------------
--  DDL for Table EHEALTH_STAT_IP_IBHW
--------------------------------------------------------

  CREATE TABLE EHEALTH_STAT_IP_IBHW 
   (	FECHA DATE, 
	ELEMENT_ID NUMBER, 
	RECEIVEBYTES NUMBER, 
	SENDBYTES NUMBER, 
	IFSPEED NUMBER, 
	RECEIVEDISCARDS NUMBER, 
	SENDDISCARDS NUMBER, 
	RECEIVEERRORS NUMBER(24,2), 
	SENDERRORS NUMBER(24,2), 
	RECEIVETOTALPKTRATE NUMBER(24,2), 
	SENDTOTALPKTRATE NUMBER(24,2), 
	INQUEUEDROPS NUMBER, 
	OUTQUEUEDROPS NUMBER, 
	UPPERCENT NUMBER(10,2), 
	SENDUTIL NUMBER(24,2), 
	SENDTOTALPKTS NUMBER, 
	SENDUCASTPKTPERCENT NUMBER(24,2), 
	SENDMCASTPKTPERCENT NUMBER(24,2), 
	SENDBCASTPKTPERCENT NUMBER(24,2), 
	SENDERRORPERCENT NUMBER(24,2), 
	SENDDISCARDPERCENT NUMBER(24,2), 
	RECEIVEUTIL NUMBER(24,2), 
	RECEIVETOTALPKTS NUMBER(24,2), 
	RECEIVEUCASTPKTPERCENT NUMBER(24,2), 
	RECEIVEMCASTPKTPERCENT NUMBER(24,2), 
	RECEIVEBCASTPKTPERCENT NUMBER(24,2), 
	RECEIVEERRORPERCENT NUMBER(24,2), 
	RECEIVEDISCARDPERCENT NUMBER(24,2), 
	SENDBCASTPKTRATE NUMBER(24,2), 
	RECEIVEBCASTPKTRATE NUMBER(24,2)
   ) NOCOMPRESS NOLOGGING
  PARTITION BY RANGE (FECHA)
  (
    PARTITION STATIPIBHW201610 VALUES LESS THAN (TO_DATE('01.11.2016','DD.MM.YYYY')) TABLESPACE TBS_SUMMARY PCTFREE 10 PCTUSED 80,
    PARTITION STATIPIBHW201611 VALUES LESS THAN (TO_DATE('01.12.2016','DD.MM.YYYY')) TABLESPACE TBS_SUMMARY PCTFREE 10 PCTUSED 80,
    PARTITION STATIPIBHW201612 VALUES LESS THAN (TO_DATE('01.01.2017','DD.MM.YYYY')) TABLESPACE TBS_SUMMARY PCTFREE 10 PCTUSED 80
  )
  TABLESPACE TBS_SUMMARY ;
--------------------------------------------------------
--  Constraints for Table EHEALTH_STAT_IP_IBHW
--------------------------------------------------------

  ALTER TABLE EHEALTH_STAT_IP_IBHW MODIFY (RECEIVEBCASTPKTRATE NOT NULL ENABLE);
  ALTER TABLE EHEALTH_STAT_IP_IBHW MODIFY (SENDBCASTPKTRATE NOT NULL ENABLE);
  ALTER TABLE EHEALTH_STAT_IP_IBHW MODIFY (RECEIVEDISCARDPERCENT NOT NULL ENABLE);
  ALTER TABLE EHEALTH_STAT_IP_IBHW MODIFY (RECEIVEERRORPERCENT NOT NULL ENABLE);
  ALTER TABLE EHEALTH_STAT_IP_IBHW MODIFY (RECEIVEBCASTPKTPERCENT NOT NULL ENABLE);
  ALTER TABLE EHEALTH_STAT_IP_IBHW MODIFY (RECEIVEMCASTPKTPERCENT NOT NULL ENABLE);
  ALTER TABLE EHEALTH_STAT_IP_IBHW MODIFY (RECEIVEUCASTPKTPERCENT NOT NULL ENABLE);
  ALTER TABLE EHEALTH_STAT_IP_IBHW MODIFY (RECEIVETOTALPKTS NOT NULL ENABLE);
  ALTER TABLE EHEALTH_STAT_IP_IBHW MODIFY (RECEIVEUTIL NOT NULL ENABLE);
  ALTER TABLE EHEALTH_STAT_IP_IBHW MODIFY (SENDDISCARDPERCENT NOT NULL ENABLE);
  ALTER TABLE EHEALTH_STAT_IP_IBHW MODIFY (SENDERRORPERCENT NOT NULL ENABLE);
  ALTER TABLE EHEALTH_STAT_IP_IBHW MODIFY (SENDBCASTPKTPERCENT NOT NULL ENABLE);
  ALTER TABLE EHEALTH_STAT_IP_IBHW MODIFY (SENDMCASTPKTPERCENT NOT NULL ENABLE);
  ALTER TABLE EHEALTH_STAT_IP_IBHW MODIFY (SENDUCASTPKTPERCENT NOT NULL ENABLE);
  ALTER TABLE EHEALTH_STAT_IP_IBHW MODIFY (SENDTOTALPKTS NOT NULL ENABLE);
  ALTER TABLE EHEALTH_STAT_IP_IBHW MODIFY (SENDUTIL NOT NULL ENABLE);
  ALTER TABLE EHEALTH_STAT_IP_IBHW MODIFY (UPPERCENT NOT NULL ENABLE);
  ALTER TABLE EHEALTH_STAT_IP_IBHW MODIFY (OUTQUEUEDROPS NOT NULL ENABLE);
  ALTER TABLE EHEALTH_STAT_IP_IBHW MODIFY (INQUEUEDROPS NOT NULL ENABLE);
  ALTER TABLE EHEALTH_STAT_IP_IBHW MODIFY (SENDTOTALPKTRATE NOT NULL ENABLE);
  ALTER TABLE EHEALTH_STAT_IP_IBHW MODIFY (RECEIVETOTALPKTRATE NOT NULL ENABLE);
  ALTER TABLE EHEALTH_STAT_IP_IBHW MODIFY (SENDERRORS NOT NULL ENABLE);
  ALTER TABLE EHEALTH_STAT_IP_IBHW MODIFY (RECEIVEERRORS NOT NULL ENABLE);
  ALTER TABLE EHEALTH_STAT_IP_IBHW MODIFY (SENDDISCARDS NOT NULL ENABLE);
  ALTER TABLE EHEALTH_STAT_IP_IBHW MODIFY (RECEIVEDISCARDS NOT NULL ENABLE);
  ALTER TABLE EHEALTH_STAT_IP_IBHW MODIFY (IFSPEED NOT NULL ENABLE);
  ALTER TABLE EHEALTH_STAT_IP_IBHW MODIFY (SENDBYTES NOT NULL ENABLE);
  ALTER TABLE EHEALTH_STAT_IP_IBHW MODIFY (RECEIVEBYTES NOT NULL ENABLE);
  ALTER TABLE EHEALTH_STAT_IP_IBHW MODIFY (ELEMENT_ID NOT NULL ENABLE);
  ALTER TABLE EHEALTH_STAT_IP_IBHW MODIFY (FECHA NOT NULL ENABLE);
