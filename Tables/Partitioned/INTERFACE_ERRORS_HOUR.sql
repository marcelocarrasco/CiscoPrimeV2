

  CREATE TABLE CSCO_INTERFACE_ERRORS_HOUR (	
  FECHA         DATE NOT NULL ENABLE, 
	NODE          VARCHAR2(255 CHAR) NOT NULL ENABLE, 
	IFEXTIFDESCR  VARCHAR2(255 CHAR) NOT NULL ENABLE, 
	INTOOSMALL    NUMBER NOT NULL ENABLE, 
	INTOOBIG      NUMBER NOT NULL ENABLE, 
	INFRAMING     NUMBER NOT NULL ENABLE, 
	INOVERRUN     NUMBER NOT NULL ENABLE, 
	INIGNORED     NUMBER NOT NULL ENABLE, 
	INABORTS      NUMBER NOT NULL ENABLE, 
	INQUEUEDROPS  NUMBER NOT NULL ENABLE, 
	OUTQUEUEDROPS NUMBER NOT NULL ENABLE, 
	 CONSTRAINT CSCO_INTERFACE_ERRORS_HOUR_PK PRIMARY KEY (FECHA, NODE, IFEXTIFDESCR)
   ) TABLESPACE TBS_HOUR
   PARTITION BY RANGE (FECHA)
   (
    PARTITION INTERFACEERRORSHOUR2016090400 VALUES LESS THAN (TO_DATE('2016.09.04 01','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090401 VALUES LESS THAN (TO_DATE('2016.09.04 02','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090402 VALUES LESS THAN (TO_DATE('2016.09.04 03','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090403 VALUES LESS THAN (TO_DATE('2016.09.04 04','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090404 VALUES LESS THAN (TO_DATE('2016.09.04 05','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090405 VALUES LESS THAN (TO_DATE('2016.09.04 06','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090406 VALUES LESS THAN (TO_DATE('2016.09.04 07','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090407 VALUES LESS THAN (TO_DATE('2016.09.04 08','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090408 VALUES LESS THAN (TO_DATE('2016.09.04 09','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090409 VALUES LESS THAN (TO_DATE('2016.09.04 10','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090410 VALUES LESS THAN (TO_DATE('2016.09.04 11','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090411 VALUES LESS THAN (TO_DATE('2016.09.04 12','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090412 VALUES LESS THAN (TO_DATE('2016.09.04 13','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090413 VALUES LESS THAN (TO_DATE('2016.09.04 14','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090414 VALUES LESS THAN (TO_DATE('2016.09.04 15','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090415 VALUES LESS THAN (TO_DATE('2016.09.04 16','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090416 VALUES LESS THAN (TO_DATE('2016.09.04 17','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090417 VALUES LESS THAN (TO_DATE('2016.09.04 18','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090418 VALUES LESS THAN (TO_DATE('2016.09.04 19','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090419 VALUES LESS THAN (TO_DATE('2016.09.04 20','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090420 VALUES LESS THAN (TO_DATE('2016.09.04 21','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090421 VALUES LESS THAN (TO_DATE('2016.09.04 22','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090422 VALUES LESS THAN (TO_DATE('2016.09.04 23','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090423 VALUES LESS THAN (TO_DATE('2016.09.05 00','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090500 VALUES LESS THAN (TO_DATE('2016.09.05 01','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090501 VALUES LESS THAN (TO_DATE('2016.09.05 02','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090502 VALUES LESS THAN (TO_DATE('2016.09.05 03','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090503 VALUES LESS THAN (TO_DATE('2016.09.05 04','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090504 VALUES LESS THAN (TO_DATE('2016.09.05 05','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090505 VALUES LESS THAN (TO_DATE('2016.09.05 06','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090506 VALUES LESS THAN (TO_DATE('2016.09.05 07','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090507 VALUES LESS THAN (TO_DATE('2016.09.05 08','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090508 VALUES LESS THAN (TO_DATE('2016.09.05 09','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090509 VALUES LESS THAN (TO_DATE('2016.09.05 10','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090510 VALUES LESS THAN (TO_DATE('2016.09.05 11','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090511 VALUES LESS THAN (TO_DATE('2016.09.05 12','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090512 VALUES LESS THAN (TO_DATE('2016.09.05 13','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090513 VALUES LESS THAN (TO_DATE('2016.09.05 14','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090514 VALUES LESS THAN (TO_DATE('2016.09.05 15','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090515 VALUES LESS THAN (TO_DATE('2016.09.05 16','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090516 VALUES LESS THAN (TO_DATE('2016.09.05 17','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090517 VALUES LESS THAN (TO_DATE('2016.09.05 18','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090518 VALUES LESS THAN (TO_DATE('2016.09.05 19','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090519 VALUES LESS THAN (TO_DATE('2016.09.05 20','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090520 VALUES LESS THAN (TO_DATE('2016.09.05 21','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090521 VALUES LESS THAN (TO_DATE('2016.09.05 22','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090522 VALUES LESS THAN (TO_DATE('2016.09.05 23','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090523 VALUES LESS THAN (TO_DATE('2016.09.06 00','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090600 VALUES LESS THAN (TO_DATE('2016.09.06 01','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090601 VALUES LESS THAN (TO_DATE('2016.09.06 02','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090602 VALUES LESS THAN (TO_DATE('2016.09.06 03','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090603 VALUES LESS THAN (TO_DATE('2016.09.06 04','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090604 VALUES LESS THAN (TO_DATE('2016.09.06 05','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090605 VALUES LESS THAN (TO_DATE('2016.09.06 06','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090606 VALUES LESS THAN (TO_DATE('2016.09.06 07','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090607 VALUES LESS THAN (TO_DATE('2016.09.06 08','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090608 VALUES LESS THAN (TO_DATE('2016.09.06 09','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090609 VALUES LESS THAN (TO_DATE('2016.09.06 10','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090610 VALUES LESS THAN (TO_DATE('2016.09.06 11','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090611 VALUES LESS THAN (TO_DATE('2016.09.06 12','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090612 VALUES LESS THAN (TO_DATE('2016.09.06 13','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090613 VALUES LESS THAN (TO_DATE('2016.09.06 14','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090614 VALUES LESS THAN (TO_DATE('2016.09.06 15','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090615 VALUES LESS THAN (TO_DATE('2016.09.06 16','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090616 VALUES LESS THAN (TO_DATE('2016.09.06 17','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090617 VALUES LESS THAN (TO_DATE('2016.09.06 18','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090618 VALUES LESS THAN (TO_DATE('2016.09.06 19','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090619 VALUES LESS THAN (TO_DATE('2016.09.06 20','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090620 VALUES LESS THAN (TO_DATE('2016.09.06 21','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090621 VALUES LESS THAN (TO_DATE('2016.09.06 22','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090622 VALUES LESS THAN (TO_DATE('2016.09.06 23','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090623 VALUES LESS THAN (TO_DATE('2016.09.07 00','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090700 VALUES LESS THAN (TO_DATE('2016.09.07 01','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090701 VALUES LESS THAN (TO_DATE('2016.09.07 02','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090702 VALUES LESS THAN (TO_DATE('2016.09.07 03','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090703 VALUES LESS THAN (TO_DATE('2016.09.07 04','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090704 VALUES LESS THAN (TO_DATE('2016.09.07 05','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090705 VALUES LESS THAN (TO_DATE('2016.09.07 06','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090706 VALUES LESS THAN (TO_DATE('2016.09.07 07','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090707 VALUES LESS THAN (TO_DATE('2016.09.07 08','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090708 VALUES LESS THAN (TO_DATE('2016.09.07 09','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090709 VALUES LESS THAN (TO_DATE('2016.09.07 10','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090710 VALUES LESS THAN (TO_DATE('2016.09.07 11','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090711 VALUES LESS THAN (TO_DATE('2016.09.07 12','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090712 VALUES LESS THAN (TO_DATE('2016.09.07 13','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090713 VALUES LESS THAN (TO_DATE('2016.09.07 14','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090714 VALUES LESS THAN (TO_DATE('2016.09.07 15','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090715 VALUES LESS THAN (TO_DATE('2016.09.07 16','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090716 VALUES LESS THAN (TO_DATE('2016.09.07 17','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090717 VALUES LESS THAN (TO_DATE('2016.09.07 18','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090718 VALUES LESS THAN (TO_DATE('2016.09.07 19','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090719 VALUES LESS THAN (TO_DATE('2016.09.07 20','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090720 VALUES LESS THAN (TO_DATE('2016.09.07 21','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090721 VALUES LESS THAN (TO_DATE('2016.09.07 22','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090722 VALUES LESS THAN (TO_DATE('2016.09.07 23','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090723 VALUES LESS THAN (TO_DATE('2016.09.08 00','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090800 VALUES LESS THAN (TO_DATE('2016.09.08 01','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090801 VALUES LESS THAN (TO_DATE('2016.09.08 02','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090802 VALUES LESS THAN (TO_DATE('2016.09.08 03','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090803 VALUES LESS THAN (TO_DATE('2016.09.08 04','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090804 VALUES LESS THAN (TO_DATE('2016.09.08 05','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090805 VALUES LESS THAN (TO_DATE('2016.09.08 06','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090806 VALUES LESS THAN (TO_DATE('2016.09.08 07','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090807 VALUES LESS THAN (TO_DATE('2016.09.08 08','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090808 VALUES LESS THAN (TO_DATE('2016.09.08 09','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090809 VALUES LESS THAN (TO_DATE('2016.09.08 10','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090810 VALUES LESS THAN (TO_DATE('2016.09.08 11','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090811 VALUES LESS THAN (TO_DATE('2016.09.08 12','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090812 VALUES LESS THAN (TO_DATE('2016.09.08 13','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090813 VALUES LESS THAN (TO_DATE('2016.09.08 14','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090814 VALUES LESS THAN (TO_DATE('2016.09.08 15','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090815 VALUES LESS THAN (TO_DATE('2016.09.08 16','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090816 VALUES LESS THAN (TO_DATE('2016.09.08 17','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090817 VALUES LESS THAN (TO_DATE('2016.09.08 18','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090818 VALUES LESS THAN (TO_DATE('2016.09.08 19','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090819 VALUES LESS THAN (TO_DATE('2016.09.08 20','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090820 VALUES LESS THAN (TO_DATE('2016.09.08 21','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090821 VALUES LESS THAN (TO_DATE('2016.09.08 22','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090822 VALUES LESS THAN (TO_DATE('2016.09.08 23','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090823 VALUES LESS THAN (TO_DATE('2016.09.09 00','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090900 VALUES LESS THAN (TO_DATE('2016.09.09 01','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090901 VALUES LESS THAN (TO_DATE('2016.09.09 02','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090902 VALUES LESS THAN (TO_DATE('2016.09.09 03','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090903 VALUES LESS THAN (TO_DATE('2016.09.09 04','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090904 VALUES LESS THAN (TO_DATE('2016.09.09 05','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090905 VALUES LESS THAN (TO_DATE('2016.09.09 06','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090906 VALUES LESS THAN (TO_DATE('2016.09.09 07','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090907 VALUES LESS THAN (TO_DATE('2016.09.09 08','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090908 VALUES LESS THAN (TO_DATE('2016.09.09 09','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090909 VALUES LESS THAN (TO_DATE('2016.09.09 10','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090910 VALUES LESS THAN (TO_DATE('2016.09.09 11','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090911 VALUES LESS THAN (TO_DATE('2016.09.09 12','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090912 VALUES LESS THAN (TO_DATE('2016.09.09 13','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090913 VALUES LESS THAN (TO_DATE('2016.09.09 14','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090914 VALUES LESS THAN (TO_DATE('2016.09.09 15','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090915 VALUES LESS THAN (TO_DATE('2016.09.09 16','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090916 VALUES LESS THAN (TO_DATE('2016.09.09 17','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090917 VALUES LESS THAN (TO_DATE('2016.09.09 18','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090918 VALUES LESS THAN (TO_DATE('2016.09.09 19','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090919 VALUES LESS THAN (TO_DATE('2016.09.09 20','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090920 VALUES LESS THAN (TO_DATE('2016.09.09 21','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090921 VALUES LESS THAN (TO_DATE('2016.09.09 22','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090922 VALUES LESS THAN (TO_DATE('2016.09.09 23','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016090923 VALUES LESS THAN (TO_DATE('2016.09.10 00','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016091000 VALUES LESS THAN (TO_DATE('2016.09.10 01','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016091001 VALUES LESS THAN (TO_DATE('2016.09.10 02','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016091002 VALUES LESS THAN (TO_DATE('2016.09.10 03','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016091003 VALUES LESS THAN (TO_DATE('2016.09.10 04','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016091004 VALUES LESS THAN (TO_DATE('2016.09.10 05','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016091005 VALUES LESS THAN (TO_DATE('2016.09.10 06','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016091006 VALUES LESS THAN (TO_DATE('2016.09.10 07','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016091007 VALUES LESS THAN (TO_DATE('2016.09.10 08','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016091008 VALUES LESS THAN (TO_DATE('2016.09.10 09','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016091009 VALUES LESS THAN (TO_DATE('2016.09.10 10','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016091010 VALUES LESS THAN (TO_DATE('2016.09.10 11','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016091011 VALUES LESS THAN (TO_DATE('2016.09.10 12','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016091012 VALUES LESS THAN (TO_DATE('2016.09.10 13','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016091013 VALUES LESS THAN (TO_DATE('2016.09.10 14','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016091014 VALUES LESS THAN (TO_DATE('2016.09.10 15','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016091015 VALUES LESS THAN (TO_DATE('2016.09.10 16','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016091016 VALUES LESS THAN (TO_DATE('2016.09.10 17','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016091017 VALUES LESS THAN (TO_DATE('2016.09.10 18','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016091018 VALUES LESS THAN (TO_DATE('2016.09.10 19','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016091019 VALUES LESS THAN (TO_DATE('2016.09.10 20','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016091020 VALUES LESS THAN (TO_DATE('2016.09.10 21','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016091021 VALUES LESS THAN (TO_DATE('2016.09.10 22','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016091022 VALUES LESS THAN (TO_DATE('2016.09.10 23','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80,
    PARTITION INTERFACEERRORSHOUR2016091023 VALUES LESS THAN (TO_DATE('2016.09.11 00','YYYY.MM.DD HH24')) TABLESPACE TBS_HOUR PCTFREE 10 PCTUSED 80
   ) NOLOGGING ;

  CREATE INDEX IDX_INTERFACE_ERR_HOUR_FECHA ON CSCO_INTERFACE_ERRORS_HOUR (TRUNC(FECHA) DESC) LOCAL
  TABLESPACE TBS_HOUR;
