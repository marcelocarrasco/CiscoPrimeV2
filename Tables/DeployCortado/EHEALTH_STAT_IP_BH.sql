--------------------------------------------------------
--  DDL for Table EHEALTH_STAT_IP_BH
--------------------------------------------------------

  CREATE TABLE EHEALTH_STAT_IP_BH 
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
   )NOCOMPRESS NOLOGGING
   PARTITION BY RANGE (FECHA)
   (
    PARTITION STATIPBH201610 VALUES LESS THAN (TO_DATE('01.11.2016','DD.MM.YYYY')) TABLESPACE TBS_DAY PCTFREE 10 PCTUSED 80,
    PARTITION STATIPBH201611 VALUES LESS THAN (TO_DATE('01.12.2016','DD.MM.YYYY')) TABLESPACE TBS_DAY PCTFREE 10 PCTUSED 80,
    PARTITION STATIPBH201612 VALUES LESS THAN (TO_DATE('01.01.2017','DD.MM.YYYY')) TABLESPACE TBS_DAY PCTFREE 10 PCTUSED 80
   )
  TABLESPACE TBS_DAY ;
--------------------------------------------------------
--  DDL for Index EHEALTH_STAT_IP_BH_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX EHEALTH_STAT_IP_BH_PK ON EHEALTH_STAT_IP_BH (FECHA, ELEMENT_ID) LOCAL
  TABLESPACE TBS_DAY ;
--------------------------------------------------------
--  Constraints for Table EHEALTH_STAT_IP_BH
--------------------------------------------------------

  ALTER TABLE EHEALTH_STAT_IP_BH ADD CONSTRAINT EHEALTH_STAT_IP_BH_PK PRIMARY KEY (FECHA, ELEMENT_ID)  ENABLE;
  ALTER TABLE EHEALTH_STAT_IP_BH MODIFY (RECEIVEBCASTPKTRATE NOT NULL ENABLE);
  ALTER TABLE EHEALTH_STAT_IP_BH MODIFY (SENDBCASTPKTRATE NOT NULL ENABLE);
  ALTER TABLE EHEALTH_STAT_IP_BH MODIFY (RECEIVEDISCARDPERCENT NOT NULL ENABLE);
  ALTER TABLE EHEALTH_STAT_IP_BH MODIFY (RECEIVEERRORPERCENT NOT NULL ENABLE);
  ALTER TABLE EHEALTH_STAT_IP_BH MODIFY (RECEIVEBCASTPKTPERCENT NOT NULL ENABLE);
  ALTER TABLE EHEALTH_STAT_IP_BH MODIFY (RECEIVEMCASTPKTPERCENT NOT NULL ENABLE);
  ALTER TABLE EHEALTH_STAT_IP_BH MODIFY (RECEIVEUCASTPKTPERCENT NOT NULL ENABLE);
  ALTER TABLE EHEALTH_STAT_IP_BH MODIFY (RECEIVETOTALPKTS NOT NULL ENABLE);
  ALTER TABLE EHEALTH_STAT_IP_BH MODIFY (RECEIVEUTIL NOT NULL ENABLE);
  ALTER TABLE EHEALTH_STAT_IP_BH MODIFY (SENDDISCARDPERCENT NOT NULL ENABLE);
  ALTER TABLE EHEALTH_STAT_IP_BH MODIFY (SENDERRORPERCENT NOT NULL ENABLE);
  ALTER TABLE EHEALTH_STAT_IP_BH MODIFY (SENDBCASTPKTPERCENT NOT NULL ENABLE);
  ALTER TABLE EHEALTH_STAT_IP_BH MODIFY (SENDMCASTPKTPERCENT NOT NULL ENABLE);
  ALTER TABLE EHEALTH_STAT_IP_BH MODIFY (SENDUCASTPKTPERCENT NOT NULL ENABLE);
  ALTER TABLE EHEALTH_STAT_IP_BH MODIFY (SENDTOTALPKTS NOT NULL ENABLE);
  ALTER TABLE EHEALTH_STAT_IP_BH MODIFY (SENDUTIL NOT NULL ENABLE);
  ALTER TABLE EHEALTH_STAT_IP_BH MODIFY (UPPERCENT NOT NULL ENABLE);
  ALTER TABLE EHEALTH_STAT_IP_BH MODIFY (OUTQUEUEDROPS NOT NULL ENABLE);
  ALTER TABLE EHEALTH_STAT_IP_BH MODIFY (INQUEUEDROPS NOT NULL ENABLE);
  ALTER TABLE EHEALTH_STAT_IP_BH MODIFY (SENDTOTALPKTRATE NOT NULL ENABLE);
  ALTER TABLE EHEALTH_STAT_IP_BH MODIFY (RECEIVETOTALPKTRATE NOT NULL ENABLE);
  ALTER TABLE EHEALTH_STAT_IP_BH MODIFY (SENDERRORS NOT NULL ENABLE);
  ALTER TABLE EHEALTH_STAT_IP_BH MODIFY (RECEIVEERRORS NOT NULL ENABLE);
  ALTER TABLE EHEALTH_STAT_IP_BH MODIFY (SENDDISCARDS NOT NULL ENABLE);
  ALTER TABLE EHEALTH_STAT_IP_BH MODIFY (RECEIVEDISCARDS NOT NULL ENABLE);
  ALTER TABLE EHEALTH_STAT_IP_BH MODIFY (IFSPEED NOT NULL ENABLE);
  ALTER TABLE EHEALTH_STAT_IP_BH MODIFY (SENDBYTES NOT NULL ENABLE);
  ALTER TABLE EHEALTH_STAT_IP_BH MODIFY (RECEIVEBYTES NOT NULL ENABLE);
  ALTER TABLE EHEALTH_STAT_IP_BH MODIFY (ELEMENT_ID NOT NULL ENABLE);
  ALTER TABLE EHEALTH_STAT_IP_BH MODIFY (FECHA NOT NULL ENABLE);
