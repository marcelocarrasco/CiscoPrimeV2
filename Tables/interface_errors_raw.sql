
-- DROP TABLE INTERFACE_ERRORS_RAW;

CREATE TABLE CSCO_INTERFACE_ERRORS_HOUR(	
  FECHA         DATE NOT NULL, 
  NODE          VARCHAR2(255 CHAR) NOT NULL, 
  IFEXTIFDESCR  VARCHAR2(255 CHAR) NOT NULL, 
  INTOOSMALL    NUMBER NOT NULL, 
  INTOOBIG      NUMBER NOT NULL, 
  INFRAMING     NUMBER NOT NULL, 
  INOVERRUN     NUMBER NOT NULL, 
  INIGNORED     NUMBER NOT NULL, 
  INABORTS      NUMBER NOT NULL, 
  INQUEUEDROPS  NUMBER NOT NULL, 
  OUTQUEUEDROPS NUMBER NOT NULL
);

CREATE TABLE CSCO_INTERFACE_ERRORS_DAY(	
  FECHA         DATE NOT NULL, 
  NODE          VARCHAR2(255 CHAR) NOT NULL, 
  IFEXTIFDESCR  VARCHAR2(255 CHAR) NOT NULL, 
  INTOOSMALL    NUMBER NOT NULL, 
  INTOOBIG      NUMBER NOT NULL, 
  INFRAMING     NUMBER NOT NULL, 
  INOVERRUN     NUMBER NOT NULL, 
  INIGNORED     NUMBER NOT NULL, 
  INABORTS      NUMBER NOT NULL, 
  INQUEUEDROPS  NUMBER NOT NULL, 
  OUTQUEUEDROPS NUMBER NOT NULL
);

CREATE TABLE CSCO_INTERFACE_ERRORS_BH(	
  FECHA         DATE NOT NULL, 
  NODE          VARCHAR2(255 CHAR) NOT NULL, 
  IFEXTIFDESCR  VARCHAR2(255 CHAR) NOT NULL, 
  INTOOSMALL    NUMBER NOT NULL, 
  INTOOBIG      NUMBER NOT NULL, 
  INFRAMING     NUMBER NOT NULL, 
  INOVERRUN     NUMBER NOT NULL, 
  INIGNORED     NUMBER NOT NULL, 
  INABORTS      NUMBER NOT NULL, 
  INQUEUEDROPS  NUMBER NOT NULL, 
  OUTQUEUEDROPS NUMBER NOT NULL
);

CREATE TABLE CSCO_INTERFACE_ERRORS_IBHW(	
  FECHA         DATE NOT NULL, 
  NODE          VARCHAR2(255 CHAR) NOT NULL, 
  IFEXTIFDESCR  VARCHAR2(255 CHAR) NOT NULL, 
  INTOOSMALL    NUMBER NOT NULL, 
  INTOOBIG      NUMBER NOT NULL, 
  INFRAMING     NUMBER NOT NULL, 
  INOVERRUN     NUMBER NOT NULL, 
  INIGNORED     NUMBER NOT NULL, 
  INABORTS      NUMBER NOT NULL, 
  INQUEUEDROPS  NUMBER NOT NULL, 
  OUTQUEUEDROPS NUMBER NOT NULL
);


--PARTITION BY RANGE (TIMESTAMP_) 
--INTERVAL(NUMTODSINTERVAL (1, 'DAY'))
--(  
--  PARTITION INTERFACE_ERRORS_RAW_FIRST VALUES LESS THAN (TO_DATE('11.04.2016','dd.mm.yyyy'))
-- );
