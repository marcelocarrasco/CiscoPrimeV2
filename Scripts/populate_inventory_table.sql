
set serveroutput on
declare
cursor rango is
select  ori.rownumber origen,
        ori.rownumber+7 destino
from  (select  rownumber,
               substr(linea,6,length(linea)) clave,
               substr(valor,8,length(valor)) valor
       from CSCO_INVENTORY_AUX
       where substr(linea,6,length(linea)) = 'CommunicationStateEnum'
       order by rownumber) ori;
--
TYPE inventory_tab IS VARRAY(10) OF VARCHAR2(255 CHAR);
--
vInventory inventory_tab := inventory_tab('','','','','','','','','');
vOrigen number;
vDestino number;
vPos number;
vInvValor varchar2(255 char):= '';
begin
  --vInvValor(1) := '0';
  open rango;
  loop
    fetch rango
    into  vOrigen,
          vDestino;
    vPos := 1;
    for i in vOrigen .. vDestino loop
      select  substr(valor,8,length(valor))
      into    vInvValor
      from CSCO_INVENTORY_AUX
      where rownumber = i;
      --
      --dbms_output.put_line(i);
      vInventory(vPos) := vInvValor;
      vPos := vPos + 1;
    end loop;
--    dbms_output.put_line(vInventory(1)||','||vInventory(2)||','||vInventory(3)||','||vInventory(4)||','||vInventory(5)||','||vInventory(6)||','||
--                        vInventory(7)||','||vInventory(8)||','||vInventory(9));
    insert into CSCO_INVENTORY (DEVICE,DEVICE_SERIES,ELEMENT_TYPE,IP_ADDRESS)
    values (vInventory(2),vInventory(3),vInventory(5),case when length(vInventory(7)) > 15 then vInventory(8) else vInventory(7) end);
    exit when rango%notfound;
  end loop;
  commit;
  close rango;
end;