-- ************** TRIGGERS **************

use inmobiliaria; 

-- 1.  Cambio de estado de una propiedad
-- -----------------------------------------------------------------------
-- cambia en la tabla historial_estado_propiedad que creé desde el inicio 

delimiter $$
create trigger trg_cambioEstadoPropiedad
after update on PROPIEDAD
for each row
begin
    declare v_estado_anterior varchar(15);
    declare v_estado_nuevo varchar(15);
    declare v_empleado_responsable int;

    -- Solo registrar si sí cambió
    IF OLD.id_estado <> NEW.id_estado THEN
        select estado into v_estado_anterior from ESTADO_PROPIEDAD where id_estado = OLD.id_estado;
        select estado into v_estado_nuevo from ESTADO_PROPIEDAD where id_estado = NEW.id_estado;

        -- Si no se registró en el update, queda el admin 1 por defecto
        SET v_empleado_responsable = ifnull(@id_empleado_actual, 1);

        insert into HISTORIAL_ESTADO_PROPIEDAD (id_propiedad, id_empleado, estado_anterior, estado_nuevo, fecha_cambio)
        values (NEW.id_propiedad, v_empleado_responsable, v_estado_anterior, v_estado_nuevo, NOW());
    END IF;
end$$
delimiter ;


-- 2. Registro de un nuevo contrato
-- -----------------------------------------------------------------------

CREATE TABLE AUDITORIA_CONTRATO (
    id_auditoria INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    id_contrato INT UNSIGNED NOT NULL,
    id_propiedad INT UNSIGNED NOT NULL,
    id_cliente BIGINT UNSIGNED NOT NULL,
    id_empleado INT UNSIGNED NOT NULL,
    accion VARCHAR(20) NOT NULL,
    fecha_evento DATETIME NOT NULL
);

alter table
    AUDITORIA_CONTRATO add constraint fk_auditoria_contrato_contrato
    foreign key (id_contrato) references CONTRATO(id_contrato);

delimiter $$
create trigger trg_contratoNuevo
after insert on CONTRATO
for each row
begin
    insert into AUDITORIA_CONTRATO (id_contrato, id_propiedad, id_cliente, id_empleado, accion, fecha_evento)
    values (NEW.id_contrato, NEW.id_propiedad, NEW.id_cliente, NEW.id_empleado, 'contrato creado', NOW());
end$$
delimiter ;


-- **** PRUEBAS ****

-- Trigger 1
SET @id_empleado_actual = 5; -- Jorge Amaya hace el cambio
 
UPDATE PROPIEDAD
SET id_estado = (SELECT id_estado FROM ESTADO_PROPIEDAD WHERE estado = 'arrendada')
WHERE id_propiedad = 16;
 
SELECT p.id_propiedad, p.id_estado, ep.estado
FROM PROPIEDAD p
JOIN ESTADO_PROPIEDAD ep ON p.id_estado = ep.id_estado
WHERE p.id_propiedad = 16;

-- Reviso si ya sale en historial
SELECT * FROM HISTORIAL_ESTADO_PROPIEDAD
WHERE id_propiedad = 16
ORDER BY fecha_cambio DESC
LIMIT 1;


-- simulo q es null para q salga admin por defecto
SET @id_empleado_actual = NULL; 
 
UPDATE PROPIEDAD
SET id_estado = (SELECT id_estado FROM ESTADO_PROPIEDAD WHERE estado = 'disponible')
WHERE id_propiedad = 16;
 
SELECT * FROM HISTORIAL_ESTADO_PROPIEDAD
WHERE id_propiedad = 16
ORDER BY fecha_cambio DESC
LIMIT 1; -- Sí salió id "1"
 
 

-- Trigger 2
 
-- Contrato de prueba (arriendo de la propiedad #16 con el cliente #10)
INSERT INTO CONTRATO (id_propiedad, id_cliente, id_empleado, fecha_firma, id_estado_contrato)
VALUES (16, 10, 7, CURDATE(), (SELECT id_estado_contrato FROM ESTADO_CONTRATO WHERE estado = 'vigente'));
 
-- id que MySQL le asignó al contrato recién insertado
SET @ultimo_contrato = LAST_INSERT_ID();
 

-- Verifico si sí sale ese mismo id_contrato, accion = 'contrato creado', y fecha_evento = ahora
SELECT * FROM AUDITORIA_CONTRATO
WHERE id_contrato = @ultimo_contrato; -- Efectivamente sí
 