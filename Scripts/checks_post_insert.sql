

--'/home/oracle/CiscoPrimeV2/exporthourly/CPU.2016-07-18-01.csv'

select nombre_csv,row_num-1
from files
where nombre_csv = '/home/oracle/CiscoPrimeV2/exporthourly/CPU.2016-07-18-01.csv'
select count(1), timestamp_
from test_cpu_raw
group by timestamp_
where to_char(timestamp_,'YYYY-MM-DD-HH24') = '2016-07-18-01';


select substr('/home/oracle/CiscoPrimeV2/exporthourly/CPU.2016-07-18-01.csv',
instr('/home/oracle/CiscoPrimeV2/exporthourly/CPU.2016-07-18-01.csv','.',1,1)+1,--pos del primer .
instr('/home/oracle/CiscoPrimeV2/exporthourly/CPU.2016-07-18-01.csv','.',1,2)-
instr('/home/oracle/CiscoPrimeV2/exporthourly/CPU.2016-07-18-01.csv','.',1,1)-1) fecha_hora
from dual;

update files set
  status = (select case
                      when tcr.cantidad - (ff.row_num -1) != 0 then 1 else 0
                   end status
            from files ff,
                 (select count(1) cantidad, timestamp_
                  from test_cpu_raw
                  group by timestamp_) tcr
            where ff.nombre_csv = '/home/oracle/CiscoPrimeV2/exporthourly/CPU.2016-07-18-00.csv'
            and to_char(tcr.timestamp_,'YYYY-MM-DD-HH24') =   substr('/home/oracle/CiscoPrimeV2/exporthourly/CPU.2016-07-18-00.csv',
                                                              instr('/home/oracle/CiscoPrimeV2/exporthourly/CPU.2016-07-18-00.csv','.',1,1)+1,--pos del primer .
                                                              instr('/home/oracle/CiscoPrimeV2/exporthourly/CPU.2016-07-18-00.csv','.',1,2)-
                                                              instr('/home/oracle/CiscoPrimeV2/exporthourly/CPU.2016-07-18-00.csv','.',1,1)-1)),
  procesado = sysdate
where nombre_csv = '/home/oracle/CiscoPrimeV2/exporthourly/CPU.2016-07-18-00.csv';
                                                  
                                                  
select case
          tcr.cantidad - (ff.row_num -1) != 0 then 1 else 0
       end status
from files ff,
     (select count(1) cantidad, timestamp_
      from test_cpu_raw
      group by timestamp_) tcr
where ff.nombre_csv = '${NOMBRE_CSV}'
and to_char(tcr.timestamp_,'YYYY-MM-DD-HH24') =   substr('${NOMBRE_CSV}',
                                                  instr('${NOMBRE_CSV}','.',1,1)+1,--pos del primer .
                                                  instr('${NOMBRE_CSV}','.',1,2)-
                                                  instr('${NOMBRE_CSV}','.',1,1)-1);                                                  