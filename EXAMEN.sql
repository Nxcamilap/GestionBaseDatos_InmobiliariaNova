-- EXAMEN

-- No pude ejecutar la bd 


use inmobiliaria;

-- ******** CONSULTAS *********

-- Consulta 1
SELECT cl.id_cliente, cl.nombre, cl.apellido, SUM(p.valor_pagado) AS ValorPagado, p.mes_pagado 
FROM CLIENTE cl
join CONTRATO co ON co.id_cliente = cl.id_cliente 
JOIN PAGO p ON p.id_contrato = co.id_contrato 
where p.mes_pagado = '2024-05'
group by p.id_contrato, cl.id_cliente;



-- Consulta 2
SELECT p.id_pago 
FROM PAGO p 
where fecha_pago >CURDATE() AND id_estado_pago= '6'; 

-- en la bd el numero 4 es "pendiente": tabla "ESTADO_PAGO"
SELECT id_estado_pago, estado  
from ESTADO_PAGO ep 
order by id_estado_pago ASC;




-- Consulta 3
SELECT cl.id_cliente, cl.nombre, cl.apellido, 
from CLIENTE cl
JOIN CONTRATO co on cl.id_cliente = co.id_cliente 
join PAGO p on p.id_contrato = co.id_contrato 
join ESTADO_PAGO ep on ep.id_estado_pago = p.id_estado_pago 
where (select COUNT(*) 
		from PAGO p2 
		where p2.id_estado_pago = '4') > 2;
	
	
	
	
-- consulta 4
-- Trigger cambio de estado de pago

	CREATE TABLE `HISTORIAL_ESTADO_PAGO`(
    `id_historial` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `id_pago` INT UNSIGNED NOT NULL,
    `id_cliente` INT UNSIGNED NOT NULL,
    `estado_anterior` VARCHAR(30) NOT NULL,
    `estado_nuevo` VARCHAR(30) NOT NULL,
    `fecha_cambio` DATETIME NOT NULL
);

ALTER TABLE
    `HISTORIAL_ESTADO_PAGO` ADD CONSTRAINT `fk_historial_pago`
    FOREIGN KEY(`id_pago`) REFERENCES `PAGO`(`id_pago`);
   
ALTER TABLE
    `HISTORIAL_ESTADO_PAGO` ADD CONSTRAINT `fk_historial_pago_cliente`
    FOREIGN KEY(`id_cliente`) REFERENCES `CLIENTE`(`id_cliente`);
   
   
   	
delimiter $$
create trigger actualizar_estado_pago
after update on PAGO
for each row
begin
    declare v_estado_anterior varchar(15);
    declare v_estado_nuevo varchar(15);
    declare v_cliente int;

    IF OLD.id_estado_pago <> NEW.id_estado_pago THEN
        select id_estado_pago into v_estado_anterior from PAGO p where id_estado_pago = OLD.id_estado;
        select id_estado_pago into v_estado_nuevo from PAGO p where id_estado_pago= NEW.id_estado and p.fecha_pago>CURDATE();
		set v_estado_nuevo= 'atrasado';

        insert into HISTORIAL_ESTADO_PAGO (id_pago, id_cliente, estado_anterior, estado_nuevo, fecha_cambio)
        values (NEW.id_estado_pago, v_cliente, v_estado_anterior, v_estado_nuevo, NOW());
    END IF;
end$$
delimiter ;
	
	
-- consulta 5

SELECT cl.nombre, cl.apellido, cl.telefono, COUNT(pr.id_propiedad) AS Propiedades
from CLIENTE cl
join PROPIEDAD pr
join PROPIETARIO p 
where cl.documento = p.documento 
GROUP BY p.documento 
order by Propiedades ASC;




