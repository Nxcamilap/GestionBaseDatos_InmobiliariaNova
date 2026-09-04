-- ***** SEGURIDAD Y USUARIOS ********


CREATE ROLE 'rol_administrador', 'rol_agente', 'rol_contador';
 
-- Admin: Todos los permisos sobre la bd
grant all privileges on inmobiliaria.* to 'rol_administrador';
 
-- AGENTE:  Gestiona propiedades y contratos, peeero solo consulta clientes (no edita) y no tiene acceso a pagos ni auditoría
grant select, insert, update on inmobiliaria.PROPIEDAD to 'rol_agente';
grant select, insert, update on inmobiliaria.CONTRATO to 'rol_agente';
grant select, insert, update on inmobiliaria.CONTRATO_VENTA to 'rol_agente';
grant select, insert, update on inmobiliaria.CONTRATO_ARRIENDO to 'rol_agente';
grant select on inmobiliaria.CLIENTE to 'rol_agente';
grant select on inmobiliaria.PROPIETARIO to 'rol_agente';
grant select on inmobiliaria.TIPO_PROPIEDAD to 'rol_agente';
grant select on inmobiliaria.ESTADO_PROPIEDAD to 'rol_agente';
grant select on inmobiliaria.ESTADO_CONTRATO to 'rol_agente';
 
-- CONTADOR: se enfoca en pagos y reportes financieros, solo consulta propiedades y contratos (noo edita) 
grant select, insert, update on inmobiliaria.PAGO to 'rol_contador';
grant select on inmobiliaria.CONTRATO to 'rol_contador';
grant select on inmobiliaria.CONTRATO_VENTA to 'rol_contador';
grant select on inmobiliaria.CONTRATO_ARRIENDO to 'rol_contador';
grant select on inmobiliaria.METODO_PAGO to 'rol_contador';
grant select on inmobiliaria.ESTADO_PAGO to 'rol_contador';
grant select on inmobiliaria.REPORTE_PAGOS_PENDIENTES to 'rol_contador';
-- la tabla REPORTE_PAGOS_PENDIENTES la creé en el archivo de eventooo)
 

-- ****** PRUEBAS ******
 
create user 'rsalazar_admin'@'%' IDENTIFIED by  'ClaveSalazar4dm1n';
grant 'rol_administrador' to 'rsalazar_admin'@'%';
set default role 'rol_administrador' to 'rsalazar_admin'@'%';
 
create user 'cjaimes_agente'@'%' IDENTIFIED by 'CambiarEstaClave123!';
grant 'rol_agente' to 'cjaimes_agente'@'%';
SET DEFAULT ROLE 'rol_agente' to 'cjaimes_agente'@'%';
 
create user 'snino_contador'@'%' IDENTIFIED BY 'CambiarEstaClave123!';
grant 'rol_contador' TO 'snino_contador'@'%';
SET DEFAULT ROLE 'rol_contador' TO 'snino_contador'@'%';
 
 
FLUSH PRIVILEGES;