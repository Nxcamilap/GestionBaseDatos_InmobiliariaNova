
-- ***** FUNCIONES PERSONALIZADAS ****

use inmobiliaria;

-- 1. Cálculo de comisión de un agente de venta
------------------------------------------------------------------------------------

-- verifico porcentajes de comisión de los agentes
select cv.porcentaje_comision, cv.id_contrato 
from contrato_venta cv 
join contrato c on c.id_contrato = cv.id_contrato 
group by c.id_contrato 
order by cv.porcentaje_comision;

--  Fórmula: Comisión = valor_venta x (porcentaje_comision / 100)

delimiter $$
create function calcularComisionVentas(id_porcentaje_comision INT)
returns decimal(10,2)
deterministic
begin
    declare v_valor_venta DECIMAL(15,2);
    declare v_porcentaje DECIMAL(15,2);
    declare v_comision DECIMAL(15,2);

    -- Traigo datos de la venta
    select valor_venta, porcentaje_comision
    into v_valor_venta, v_porcentaje
    from CONTRATO_VENTA
    where id_contrato = id_porcentaje_comision; -- id del contrato para sacar la comisión

    SET v_comision = v_valor_venta * (v_porcentaje / 100);

    return v_comision;
end$$
delimiter ;


-- 2. Cálculo deuda pendiente de contratos de arriendo
---------------------------------------------------------------------------------------

--   verifico meses pasados desde que inició el contrato
--   verifico cuánto debería haber pagado en total (meses x valor mensual)
--   verifico cuánto ha pagado realmente (suma de la tabla pago)
--   Formula de la deuda = lo que debería haber pagado - lo que ya pagó
delimiter $$
create function calcularDeudaPendiente(p_id_contrato int)
returns decimal(10,2)
deterministic
begin
    declare v_valor_arriendo decimal(10,2);
    declare v_fecha_inicio date;
    declare v_fecha_fin date;
    declare v_fecha_limite date;
    declare v_meses_transcurridos int;
    declare v_total_esperado decimal(10,2);
    declare v_total_pagado decimal(10,2);
    declare v_deuda decimal(10,2);

    -- Traemos los datos del contrato de arriendo
    select valor_arriendo, fecha_inicio, fecha_fin
    into v_valor_arriendo, v_fecha_inicio, v_fecha_fin
    from CONTRATO_ARRIENDO
    where id_contrato = p_id_contrato;

    set  v_fecha_limite = LEAST(CURDATE(), v_fecha_fin);  
    -- Si sigue vigente, cuenta meses hasta hoy.
    -- sino, cuenta meses solo hasta la fecha_fin si el contrato ya terminó

    set v_meses_transcurridos = TIMESTAMPDIFF(MONTH, v_fecha_inicio, v_fecha_limite) + 1; 
    -- cuenta cuantos meses completos han pasado desde la fecha inicio a la limite
	-- +1 pq si incia hoy ya debe 1 mes
    
    IF v_meses_transcurridos < 0 THEN
        set v_meses_transcurridos = 0;
    END IF;

    -- Lo que debería haber pagado hasta hoy
    set v_total_esperado = v_meses_transcurridos * v_valor_arriendo;

    -- Lo que está pago
    select ifnull(sum(valor_pagado), 0)
    into v_total_pagado
    from PAGO
    where id_contrato = p_id_contrato;

    SET v_deuda = v_total_esperado - v_total_pagado;

    RETURN v_deuda;
END$$
delimiter ;


-- 3. Total de propiedades disponibles por tipo
---------------------------------------------------------------------------------------

-- verifico total propiedades
select tp.tipo as 'Tipo Propiedad', count(p.id_propiedad) as Total
from propiedad p 
join tipo_propiedad tp on p.id_tipo_propiedad = tp.id_tipo_propiedad
group by tp.id_tipo_propiedad;

-- verifico total de propiedades disponibles
select tp.tipo as 'Tipo Propiedad', count(p.id_propiedad) as Total
from propiedad p 
join tipo_propiedad tp on p.id_tipo_propiedad = tp.id_tipo_propiedad
join estado_propiedad ep on ep.id_estado = p.id_estado 
where ep.estado = 'disponible'
group by tp.id_tipo_propiedad; 


delimiter $$
create function propiedadesDisponiblesPorTipo(p_tipo varchar(20)) -- Buscar casa, apto o local
returns int
deterministic
begin
    declare v_total INT;

    select COUNT(*)
    into v_total
    from PROPIEDAD p
    join TIPO_PROPIEDAD tp ON p.id_tipo_propiedad = tp.id_tipo_propiedad
    join ESTADO_PROPIEDAD ep ON p.id_estado = ep.id_estado
    where tp.tipo = p_tipo AND ep.estado = 'disponible';

    return v_total;
end$$

delimiter ;

--- **** PRUEBAS ****

-- Comisión del contrato de venta #3 (Provenza, 280.000.000, 4%)
select calcularComisionVentas(3) AS comision;

-- Deuda pendiente del contrato de arriendo #16 (Álvarez, 2.500.000/mes)
-- Pagó abril y mayo 2023 
select calcularDeudaPendiente(16) AS deuda;

-- Propiedades disponibles
select propiedadesDisponiblesPorTipo('local') AS disponibles;
select propiedadesDisponiblesPorTipo('apto') AS disponibles;
select propiedadesDisponiblesPorTipo('casa') AS disponibles;

SHOW FUNCTION STATUS WHERE Db = 'inmobiliaria';

