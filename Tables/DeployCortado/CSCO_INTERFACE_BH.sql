-- DROP TABLE CSCO_INTERFACE_BH PURGE;

CREATE TABLE CSCO_INTERFACE_BH(
FECHA	                  DATE,
NODE	                  VARCHAR2(255 CHAR),
INTERFAZ	              VARCHAR2(255 CHAR),
IFINDEX	                NUMBER,
IFTYPE	                NUMBER,
IFSPEED	                NUMBER(24,2),
SENDUTIL	              NUMBER(24,2),
SENDTOTALPKTS	          NUMBER,
SENDTOTALPKTRATE	      NUMBER(24,2),
SENDBYTES	              NUMBER,
SENDBYTERATE	          NUMBER(24,2),
SENDBITRATE	            NUMBER(24,2),
SENDUCASTPKTPERCENT	    NUMBER(24,2),
SENDMCASTPKTPERCENT	    NUMBER(24,2),
SENDBCASTPKTPERCENT	    NUMBER(24,2),
SENDERRORS	            NUMBER(24,2),
SENDERRORPERCENT	      NUMBER(24,2),
SENDDISCARDS	          NUMBER(24,2),
SENDDISCARDPERCENT	    NUMBER(24,2),
RECEIVEUTIL	            NUMBER(24,2),
RECEIVETOTALPKTS	      NUMBER(24,2),
RECEIVETOTALPKTRATE	    NUMBER(24,2),
RECEIVEBYTES	          NUMBER(24,2),
RECEIVEBYTERATE	        NUMBER(24,2),
RECEIVEBITRATE	        NUMBER(24,2),
RECEIVEUCASTPKTPERCENT	NUMBER(24,2),
RECEIVEMCASTPKTPERCENT	NUMBER(24,2),
RECEIVEBCASTPKTPERCENT	NUMBER(24,2),
RECEIVEERRORS	          NUMBER(24,2),
RECEIVEERRORPERCENT	    NUMBER(24,2),
RECEIVEDISCARDS	        NUMBER(24,2),
RECEIVEDISCARDPERCENT	  NUMBER(24,2),
SENDBCASTPKTRATE	      NUMBER(24,2),
RECEIVEBCASTPKTRATE	    NUMBER(24,2),
IFTYPESTRING	          VARCHAR2(255 CHAR),
MAX_SEND_RECEIVE	      NUMBER
)
NOCOMPRESS
NOLOGGING
PARTITION BY RANGE (FECHA)
INTERVAL(NUMTODSINTERVAL(1, 'DAY'))
(
  PARTITION INTERFACEBH_FIRST VALUES LESS THAN (TO_DATE('01.10.2016','DD.MM.YYYY'))
)
TABLESPACE TBS_DAY;

CREATE INDEX IDX_INTERFACE_BH_FNI ON CSCO_INTERFACE_BH (FECHA,NODE,INTERFAZ) LOCAL TABLESPACE TBS_DAY;
CREATE INDEX IDX_INTERFACE_BH_F ON CSCO_INTERFACE_BH TO_CHAR(FECHA,'DD.MM.YYYY') LOCAL TABLESPACE TBS_DAY;

CREATE PUBLIC SYNONYM CSCO_INTERFACE_BH FOR SMART.CSCO_INTERFACE_BH;