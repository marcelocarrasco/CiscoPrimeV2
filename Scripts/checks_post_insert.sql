

--'/home/oracle/CiscoPrimeV2/exporthourly/CPU.2016-07-18-01.csv'

select nombre_csv,row_num-1
from files
where nombre_csv = '/home/oracle/CiscoPrimeV2/exporthourly/CPU.2016-07-18-01.csv'
select count(1), timestamp_
from test_cpu_raw
group by timestamp_
where to_char(timestamp_,'YYYY-MM-DD-HH24') = '2016-07-18-01';


select substr('/home/oracle/CiscoPrimeV2/exporthourly/MEMORY.2016-07-21-01.csv',
instr('/home/oracle/CiscoPrimeV2/exporthourly/MEMORY.2016-07-21-01.csv','.',1,1)+1,13)--pos del primer .
--instr('/home/oracle/CiscoPrimeV2/exporthourly/CPU.2016-07-18-01.csv','.',1,2)-
--instr('/home/oracle/CiscoPrimeV2/exporthourly/CPU.2016-07-18-01.csv','.',1,1)-1) fecha_hora
from dual;

update files set
  status = (select case
                      when tcr.cantidad - (ff.row_num -1) != 0 then 1 else 0
                   end status
            from files ff,
                 (select count(1) cantidad, FECHA
                  from csco_cpu_hour
                  group by FECHA) tcr
            where ff.nombre_csv = '/home/oracle/CiscoPrimeV2/exporthourly/CPU.2016-07-18-12_-2.csv'
            and to_char(tcr.FECHA,'YYYY-MM-DD-HH24') =   substr('/home/oracle/CiscoPrimeV2/exporthourly/CPU.2016-07-18-12_-2.csv',
                                                              instr('/home/oracle/CiscoPrimeV2/exporthourly/CPU.2016-07-18-12_-2.csv','.',1,1)+1,--pos del primer .
                                                              instr('/home/oracle/CiscoPrimeV2/exporthourly/CPU.2016-07-18-12_-2.csv','.',1,2)-
                                                              instr('/home/oracle/CiscoPrimeV2/exporthourly/CPU.2016-07-18-12_-2.csv','.',1,1)-1)),
  procesado = sysdate
where nombre_csv = '/home/oracle/CiscoPrimeV2/exporthourly/CPU.2016-07-18-12_-2.csv';
                                                  
                                                  
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
                                                  
                                                  
                                                  
select 
case
          when tcr.cantidad - (ff.row_num -1) != 0 then 1 
          when tcr.cantidad - (ff.row_num -1) = 0 then 0
          else -1
       end status
from files ff
,
     (select count(1) cantidad, FECHA
      from csco_memory_hour
      group by FECHA) tcr
where ff.nombre_csv = '/home/oracle/CiscoPrimeV2/exporthourly/MEMORY.2016-07-21-01.csv'
and to_char(tcr.FECHA,'YYYY-MM-DD-HH24') =   
substr('/home/oracle/CiscoPrimeV2/exporthourly/MEMORY.2016-07-21-01.csv',
instr('/home/oracle/CiscoPrimeV2/exporthourly/MEMORY.2016-07-21-01.csv','.',1,1)+1,13) --pos del primer .
--instr('/home/oracle/CiscoPrimeV2/exporthourly/CPU.2016-07-18-12_-2.csv','.',1,2)-
--instr('/home/oracle/CiscoPrimeV2/exporthourly/CPU.2016-07-18-12_-2.csv','.',1,1)-1)


declare
  vNombreCsv VARCHAR2(500 CHAR) := '/home/oracle/CiscoPrimeV2/exporthourly/MEMORY_DEVICE_AVERAGE.';
begin 
merge into files fl
using (select th.fecha_tabla_hour  fecha_tabla_hour,
                  case
                    when (th.cnt_hour - tf.cnt_files) != 0 then 1
                    when (th.cnt_hour - tf.cnt_files) = 0 then 0
                    else -1
                  end total
          from  (--filas provenientes de la tabla hour
                select  to_char(fecha,'YYYY-MM-DD-HH24') fecha_tabla_hour,
                        count(1) cnt_hour
                from csco_MEMORY_DEVICE_AVG_hour --VARIABLE ${TABLA_HOUR}
                where to_char(fecha,'YYYY-MM-DD-HH24') in ( select substr(nombre_csv,instr(nombre_csv,'.',1,1)+1,13) 
                                                          from  (--set de datos
                                                                select *
                                                                from files
                                                                where status = 1
                                                                and nombre_csv like vNombreCsv||'%'))
                group by to_char(fecha,'YYYY-MM-DD-HH24')) th,
                (--filas provenientes de la tabla files 
                select  substr(nombre_csv,instr(nombre_csv,'.',1,1)+1,13) fecha_files,
                        sum(row_num-1) cnt_files
                from files 
                where substr(nombre_csv,instr(nombre_csv,'.',1,1)+1,13) in (--set de datos
                                                                            select substr(nombre_csv,instr(nombre_csv,'.',1,1)+1,13) fecha
                                                                            from files
                                                                            where status = 1
                                                                            and nombre_csv like vNombreCsv||'%')
                and nombre_csv like vNombreCsv||'%'
                group by substr(nombre_csv,instr(nombre_csv,'.',1,1)+1,13)) tf
          where th.fecha_tabla_hour = tf.fecha_files
          order by 1) datos
on (substr(fl.nombre_csv,instr(nombre_csv,'.',1,1)+1,13) = datos.fecha_tabla_hour)
when matched then
  update set
    procesado = sysdate,
    status = datos.total;
end;



select nombre_csv,'''%'||substr(nombre_csv,instr(nombre_csv,'.',1,1)+1,13)||'%'''
from files;

