-- ****** Optimizacion y eventos *******
 
-- Tabla donde se guarda el reporte cada vez que el evento se ejecuta
CREATE TABLE REPORTE_PAGOS_PENDIENTES (
    id_reporte INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    id_contrato INT UNSIGNED NOT NULL,
    deuda_pendiente DECIMAL(15,2) NOT NULL,
    fecha_generacion DATETIME NOT NULL
);

alter table
    REPORTE_PAGOS_PENDIENTES add constraint fk_reporteContrato
    foreign key(id_contrato) references CONTRATO(id_contrato);
 
-- Aqui enciendo el "Event Scheduler"
SET GLOBAL event_scheduler = ON;
 
delimiter $$
create EVENT ev_reportePagosPendientes
on schedule every 1 month 
starts current_timestamp  
do
begin
    -- Calculo deuda pendiente por cada contrato arriendo
    insert into REPORTE_PAGOS_PENDIENTES (id_contrato, deuda_pendiente, fecha_generacion)
    select id_contrato, calcularDeudaPendiente(id_contrato), NOW()
    from CONTRATO_ARRIENDO
    where calcularDeudaPendiente(id_contrato) > 0;
end$$
delimiter ;
 


-- ****** PRUEBAS ******

SHOW EVENTS FROM inmobiliaria;
SHOW VARIABLES LIKE 'event_scheduler';
 
-- Arriendos con deuda pendiente
select * from REPORTE_PAGOS_PENDIENTES order by fecha_generacion desc;
 
-- Comprobar q sirva cada min
delimiter $$
create EVENT ev_prueba_reporte_10sec
on SCHEDULE every 10 second
do
begin
   insert into REPORTE_PAGOS_PENDIENTES (id_contrato, deuda_pendiente, fecha_generacion)
    select id_contrato, calcularDeudaPendiente(id_contrato), NOW()
    from CONTRATO_ARRIENDO
    where calcularDeudaPendiente(id_contrato) > 0;
end$$
delimiter ;
 
-- Espera un poco más de 1 minuto y revisa: debe haber una fila nueva
-- con fecha_generacion cercana a "ahora + 1 minuto"
select * from REPORTE_PAGOS_PENDIENTES order by fecha_generacion desc;
 
-- Limpieza: borra el evento de prueba, ya no lo necesitas
drop EVENT if exists ev_prueba_reporte_10sec;
 