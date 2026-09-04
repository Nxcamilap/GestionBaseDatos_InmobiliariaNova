-- ******* INDICES *****

------------------------------------------------------------------------------------------------------------------------------
-- Nota personal:  Las llaves foráneas ya crean un índice automáticamente en MySQL, así
-- que no hace falta indexarlas de nuevo. Aquí seagregan índices en
-- columnas que NO son FK pero que sí se usan mucho para filtrar o
-- buscar (WHERE, ORDER BY), que es donde un índice realmente ayuda.
-- ---------------------------------------------------------------------------------------------------------------------------
 
-- Buscar pagos por fecha 
create index  idx_pago_fecha on pago (fecha_pago);
 
-- Buscar pagos de un contrato ordenados por fecha
create index  idx_pago_contrato_fecha on pago (id_contrato, fecha_pago);
 
-- Buscar contratos por fecha de firma 
create index  idx_contrato_fecha_firma on contrato (fecha_firma);
 
-- Buscar propiedades por ciudad 
create index  idx_propiedad_ciudad on propiedad (ciudad); -- En la bd solo registré Bucaramanga, Florida y Piedecuesta


-- ******** PRUEBAS ********

explain select * from pago where fecha_pago = '2024-01-06';
explain select  * from contrato where fecha_firma = '2023-05-22';
explain select  * from propiedad where ciudad = 'Piedecuesta';

 