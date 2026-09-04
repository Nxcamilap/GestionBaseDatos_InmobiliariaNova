-- ************ Base de datos: Inmobiliaria Nova  ************

use inmobiliaria ;


CREATE TABLE `ROL`(
    `id_rol` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `nombre_rol` VARCHAR(20) NOT NULL
);

CREATE TABLE `TIPO_PROPIEDAD`(
    `id_tipo_propiedad` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `tipo` VARCHAR(10) NOT NULL
);

CREATE TABLE `ESTADO_PROPIEDAD`(
    `id_estado` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `estado` VARCHAR(15) NOT NULL
);

CREATE TABLE `ESTADO_CONTRATO`(
    `id_estado_contrato` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `estado` VARCHAR(10) NOT NULL
);

CREATE TABLE `METODO_PAGO`(
    `id_metodo_pago` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `metodo` VARCHAR(15) NOT NULL
);

CREATE TABLE `ESTADO_PAGO`(
    `id_estado_pago` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `estado` VARCHAR(15) NOT NULL
);

CREATE TABLE `PROPIETARIO`(
    `id_propietario` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `documento` INT(10) NOT NULL,
    `nombre` VARCHAR(50) NOT NULL,
    `apellido` VARCHAR(50) NOT NULL,
    `telefono` INT(10) NOT NULL,
    `banco` VARCHAR(50) NOT NULL,
    `num_cuenta` INT(50) NOT NULL
);

alter table PROPIETARIO
    modify telefono int(10) unsigned not null;

alter table propietario
    modify num_cuenta bigint unsigned not null;

ALTER TABLE
    `PROPIETARIO` ADD UNIQUE `propietario_documento_unique`(`documento`);

CREATE TABLE `CLIENTE`(
    `id_cliente` INT  UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `documento` INT(10) NOT NULL,
    `nombre` VARCHAR(50) NOT NULL,
    `apellido` VARCHAR(50) NOT NULL,
    `telefono` INT(10) NOT NULL
);

alter table CLIENTE
    modify telefono int(20) unsigned not null;

ALTER TABLE
    `CLIENTE` ADD UNIQUE `cliente_documento_unique`(`documento`);

CREATE TABLE `EMPLEADO`(
    `id_empleado` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `documento` INT(10) NOT NULL,
    `nombre` VARCHAR(50) NOT NULL,
    `apellido` VARCHAR(50) NOT NULL,
    `telefono` INT(10) NOT NULL,
    `id_rol` INT UNSIGNED NOT NULL,
    `usuario_mysql` VARCHAR(50) NOT NULL,
    `fecha_vinculacion` DATE NOT NULL,
    `estado` VARCHAR(8) NOT NULL
);

alter table EMPLEADO
    modify telefono int(20) unsigned not null;

ALTER TABLE
    `EMPLEADO` ADD UNIQUE `empleado_documento_unique`(`documento`);
ALTER TABLE
    `EMPLEADO` ADD UNIQUE `empleado_usuario_mysql_unique`(`usuario_mysql`);

CREATE TABLE `PROPIEDAD`(
    `id_propiedad` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `barrio` VARCHAR(30) NOT NULL,
    `ciudad` VARCHAR(30) NOT NULL,
    `id_tipo_propiedad` INT UNSIGNED NOT NULL,
    `id_propietario` INT UNSIGNED NOT NULL,
    `id_empleado` INT UNSIGNED NOT NULL,
    `valor_venta` FLOAT(53) NOT NULL,
    `valor_arriendo` FLOAT(53) NOT NULL,
    `id_estado` INT UNSIGNED NOT NULL
);

CREATE TABLE `CONTRATO`(
    `id_contrato` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `id_propiedad` INT UNSIGNED NOT NULL,
    `id_cliente` BIGINT UNSIGNED NOT NULL,
    `id_empleado` INT UNSIGNED NOT NULL,
    `fecha_firma` DATE NOT NULL,
    `id_estado_contrato` INT UNSIGNED NOT NULL
);
alter table CONTRATO
    modify id_cliente int unsigned not null;

CREATE TABLE `CONTRATO_VENTA`(
    `id_contrato` INT UNSIGNED NOT NULL PRIMARY KEY,
    `valor_venta` FLOAT(53) NOT NULL,
    `fecha_escritura` DATE NOT NULL,
    `porcentaje_comision` FLOAT(53) NOT NULL
);

CREATE TABLE `CONTRATO_ARRIENDO`(
    `id_contrato` INT UNSIGNED NOT NULL PRIMARY KEY,
    `valor_arriendo` FLOAT(53) NOT NULL,
    `fecha_inicio` DATE NOT NULL,
    `fecha_fin` DATE NOT NULL,
    `dia_pago` INT NOT NULL
);

CREATE TABLE `PAGO`(
    `id_pago` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `id_contrato` INT UNSIGNED NOT NULL,
    `fecha_pago` DATE NOT NULL,
    `valor_pagado` FLOAT(53) NOT NULL,
    `mes_pagado` VARCHAR(30) NOT NULL,
    `id_metodo_pago` BIGINT UNSIGNED NOT NULL,
    `id_estado_pago` INT UNSIGNED NOT NULL
);

CREATE TABLE `HISTORIAL_ESTADO_PROPIEDAD`(
    `id_historial` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `id_propiedad` INT UNSIGNED NOT NULL,
    `id_empleado` INT UNSIGNED NOT NULL,
    `estado_anterior` VARCHAR(30) NOT NULL,
    `estado_nuevo` VARCHAR(30) NOT NULL,
    `fecha_cambio` DATETIME NOT NULL
);

-- FOREIGN KEYS: 

ALTER TABLE
    `EMPLEADO` ADD CONSTRAINT `fk_empleado_rol`
    FOREIGN KEY(`id_rol`) REFERENCES `ROL`(`id_rol`);

ALTER TABLE
    `PROPIEDAD` ADD CONSTRAINT `fk_propiedad_tipo_propiedad`
    FOREIGN KEY(`id_tipo_propiedad`) REFERENCES `TIPO_PROPIEDAD`(`id_tipo_propiedad`);

ALTER TABLE
    `PROPIEDAD` ADD CONSTRAINT `fk_propiedad_estado_propiedad`
    FOREIGN KEY(`id_estado`) REFERENCES `ESTADO_PROPIEDAD`(`id_estado`);

ALTER TABLE
    `PROPIEDAD` ADD CONSTRAINT `fk_propiedad_propietario`
    FOREIGN KEY(`id_propietario`) REFERENCES `PROPIETARIO`(`id_propietario`);

-- PROPIEDAD (muchos) -> EMPLEADO (uno)
ALTER TABLE
    `PROPIEDAD` ADD CONSTRAINT `fk_propiedad_empleado`
    FOREIGN KEY(`id_empleado`) REFERENCES `EMPLEADO`(`id_empleado`);

ALTER TABLE
    `CONTRATO` ADD CONSTRAINT `fk_contrato_propiedad`
    FOREIGN KEY(`id_propiedad`) REFERENCES `PROPIEDAD`(`id_propiedad`);

ALTER TABLE
    `CONTRATO` ADD CONSTRAINT `fk_contrato_cliente`
    FOREIGN KEY(`id_cliente`) REFERENCES `CLIENTE`(`id_cliente`);

ALTER TABLE
    `CONTRATO` ADD CONSTRAINT `fk_contrato_empleado`
    FOREIGN KEY(`id_empleado`) REFERENCES `EMPLEADO`(`id_empleado`);

ALTER TABLE
    `CONTRATO` ADD CONSTRAINT `fk_contrato_estado_contrato`
    FOREIGN KEY(`id_estado_contrato`) REFERENCES `ESTADO_CONTRATO`(`id_estado_contrato`);

ALTER TABLE
    `CONTRATO_VENTA` ADD CONSTRAINT `fk_contrato_venta_contrato`
    FOREIGN KEY(`id_contrato`) REFERENCES `CONTRATO`(`id_contrato`);

ALTER TABLE
    `CONTRATO_ARRIENDO` ADD CONSTRAINT `fk_contrato_arriendo_contrato`
    FOREIGN KEY(`id_contrato`) REFERENCES `CONTRATO`(`id_contrato`);

ALTER TABLE
    `PAGO` ADD CONSTRAINT `fk_pago_contrato`
    FOREIGN KEY(`id_contrato`) REFERENCES `CONTRATO`(`id_contrato`);

ALTER TABLE
    `PAGO` ADD CONSTRAINT `fk_pago_metodo_pago`
    FOREIGN KEY(`id_metodo_pago`) REFERENCES `METODO_PAGO`(`id_metodo_pago`);

ALTER TABLE
    `PAGO` ADD CONSTRAINT `fk_pago_estado_pago`
    FOREIGN KEY(`id_estado_pago`) REFERENCES `ESTADO_PAGO`(`id_estado_pago`);

ALTER TABLE
    `HISTORIAL_ESTADO_PROPIEDAD` ADD CONSTRAINT `fk_historial_propiedad`
    FOREIGN KEY(`id_propiedad`) REFERENCES `PROPIEDAD`(`id_propiedad`);

ALTER TABLE
    `HISTORIAL_ESTADO_PROPIEDAD` ADD CONSTRAINT `fk_historial_empleado`
    FOREIGN KEY(`id_empleado`) REFERENCES `EMPLEADO`(`id_empleado`);





--  ************* INSERCIONES *************

use inmobiliaria;
INSERT INTO `ROL` (`nombre_rol`) VALUES
('administrador'),
('agente'),
('contador');

INSERT INTO `TIPO_PROPIEDAD` (`tipo`) VALUES
('casa'),
('apto'),
('local');

INSERT INTO `ESTADO_PROPIEDAD` (`estado`) VALUES
('disponible'),
('arrendada'),
('vendida'),
('mantenimiento');

INSERT INTO `ESTADO_CONTRATO` (`estado`) VALUES
('vigente'),
('finalizado'),
('incumplido');

INSERT INTO `METODO_PAGO` (`metodo`) VALUES
('efectivo'),
('transferencia'),
('tarjeta'),
('cheque');

INSERT INTO `ESTADO_PAGO` (`estado`) VALUES
('a tiempo'),
('atrasado'),
('parcial');

-- ---------------------------------------------------------------------
-- PROPIETARIO 
-- ---------------------------------------------------------------------

INSERT INTO `PROPIETARIO` (`documento`, `nombre`, `apellido`, `telefono`, `banco`, `num_cuenta`) VALUES
('1098234561', 'Carlos', 'Ramírez', '3001234561', 'Bancolombia', '21098765432'),
('1099345672', 'Diana', 'Torres', '3012345672', 'Davivienda', '21098765433'),
('1100456783', 'Jorge', 'Suárez', '3023456783', 'BBVA', '21098765434'),
('1101567894', 'Marcela', 'Gómez', '3034567894', 'Bancolombia', '21098765435'),
('1102678905', 'Andrés', 'Villamizar', '3045678905', 'Banco de Bogotá', '21098765436'),
('1103789016', 'Patricia', 'Rojas', '3056789016', 'Davivienda', '21098765437'),
('1104890127', 'Fernando', 'Mantilla', '3067890127', 'Bancolombia', '21098765438'),
('1105901238', 'Lucía', 'Cárdenas', '3078901238', 'BBVA', '21098765439'),
('1106012349', 'Ricardo', 'Duarte', '3089012349', 'Banco de Bogotá', '21098765440'),
('1107123450', 'Sandra', 'Peña', '3090123450', 'Davivienda', '21098765441'),
('1108234561', 'Miguel', 'Ortiz', '3101234561', 'Bancolombia', '21098765442'),
('1109345672', 'Claudia', 'Serrano', '3112345672', 'BBVA', '21098765443'),
('1110456783', 'Esteban', 'Niño', '3123456783', 'Banco de Bogotá', '21098765444'),
('1111567894', 'Natalia', 'Rueda', '3134567894', 'Davivienda', '21098765445'),
('1112678905', 'Camilo', 'Prada', '3145678905', 'Bancolombia', '21098765446');

-- ---------------------------------------------------------------------
-- CLIENTE 
-- ---------------------------------------------------------------------
INSERT INTO `CLIENTE` (`documento`, `nombre`, `apellido`, `telefono`) VALUES
('1013234561', 'Laura', 'Gómez', '3151234561'),
('1014345672', 'Sebastián', 'Díaz', '3162345672'),
('1015456783', 'Valentina', 'López', '3173456783'),
('1016567894', 'Julián', 'Cárdenas', '3184567894'),
('1017678905', 'Daniela', 'Moreno', '3195678905'),
('1018789016', 'Felipe', 'Rincón', '3206789016'),
('1019890127', 'Paola', 'Sánchez', '3217890127'),
('1020901238', 'Andrés', 'Castellanos', '3228901238'),
('1021012349', 'Carolina', 'Vega', '3239012349'),
('1022123450', 'Mauricio', 'Delgado', '3240123450'),
('1023234561', 'Tatiana', 'Blanco', '3251234561'),
('1024345672', 'Nelson', 'Quintero', '3262345672'),
('1025456783', 'Ximena', 'Rojas', '3273456783'),
('1026567894', 'Camilo', 'Herrera', '3284567894'),
('1027678905', 'Adriana', 'Puentes', '3295678905');

-- ---------------------------------------------------------------------
-- EMPLEADO 
-- ---------------------------------------------------------------------
INSERT INTO `EMPLEADO` (`documento`, `nombre`, `apellido`, `telefono`, `id_rol`, `usuario_mysql`, `fecha_vinculacion`, `estado`) VALUES
('91234561', 'Roberto', 'Salazar', '3301234561', 1, 'rsalazar_admin', '2020-01-15', 'activo'),
('91234562', 'Beatriz', 'Cala', '3301234562', 1, 'bcala_admin', '2020-03-10', 'activo'),
('91234563', 'Carlos', 'Jaimes', '3301234563', 2, 'cjaimes_agente', '2021-02-01', 'activo'),
('91234564', 'Diana', 'Rueda', '3301234564', 2, 'drueda_agente', '2021-04-12', 'activo'),
('91234565', 'Jorge', 'Amaya', '3301234565', 2, 'jamaya_agente', '2021-06-20', 'activo'),
('91234566', 'Marcela', 'Ortiz', '3301234566', 2, 'mortiz_agente', '2021-08-05', 'activo'),
('91234567', 'Andrés', 'Pabón', '3301234567', 2, 'apabon_agente', '2022-01-10', 'activo'),
('91234568', 'Patricia', 'Silva', '3301234568', 2, 'psilva_agente', '2022-03-15', 'activo'),
('91234569', 'Fernando', 'Galvis', '3301234569', 2, 'fgalvis_agente', '2022-05-22', 'activo'),
('91234570', 'Lucía', 'Barrera', '3301234570', 2, 'lbarrera_agente', '2022-09-01', 'inactivo'),
('91234571', 'Ricardo', 'Cote', '3301234571', 2, 'rcote_agente', '2023-01-18', 'activo'),
('91234572', 'Sandra', 'Niño', '3301234572', 3, 'snino_contador', '2020-11-01', 'activo'),
('91234573', 'Miguel', 'Rangel', '3301234573', 3, 'mrangel_contador', '2021-07-14', 'activo'),
('91234574', 'Claudia', 'Duran', '3301234574', 3, 'cduran_contador', '2022-02-28', 'activo'),
('91234575', 'Esteban', 'Villalba', '3301234575', 3, 'evillalba_contador', '2023-05-09', 'activo');

-- ---------------------------------------------------------------------
-- PROPIEDAD
-- id_tipo_propiedad: 1=casa 2=apartamento 3=local comercial
-- id_estado: 1=disponible 2=arrendada 3=vendida 4=mantenimiento
-- ---------------------------------------------------------------------

INSERT INTO `PROPIEDAD` (`barrio`, `ciudad`, `id_tipo_propiedad`, `id_propietario`, `id_empleado`, `valor_venta`, `valor_arriendo`, `id_estado`) VALUES
('Cabecera del Llano', 'Bucaramanga', 2, 1, 3, 320000000, 1800000, 3),
('Álvarez', 'Floridablanca', 1, 2, 4, 450000000, 2500000, 2),
('Provenza', 'Bucaramanga', 2, 3, 5, 280000000, 1600000, 1),
('Cañaveral', 'Floridablanca', 1, 4, 6, 520000000, 2800000, 2),
('Centro', 'Piedecuesta', 3, 5, 7, 190000000, 1400000, 1),
('La Aurora', 'Bucaramanga', 2, 6, 8, 260000000, 1500000, 3),
('Mutis', 'Bucaramanga', 1, 7, 9, 480000000, 2600000, 2),
('Real de Minas', 'Bucaramanga', 2, 8, 3, 300000000, 1700000, 1),
('Lagos del Cacique', 'Bucaramanga', 1, 9, 4, 550000000, 3000000, 2),
('Bucarica', 'Floridablanca', 2, 10, 5, 270000000, 1550000, 4),
('San Alonso', 'Piedecuesta', 3, 11, 6, 210000000, 1450000, 1),
('Ciudadela Real de Minas', 'Bucaramanga', 1, 12, 7, 470000000, 2450000, 2),
('Café Madrid', 'Bucaramanga', 2, 13, 8, 250000000, 1500000, 3),
('El Prado', 'Bucaramanga', 3, 14, 9, 230000000, 1600000, 1),
('Villa Sofía', 'Floridablanca', 1, 15, 3, 500000000, 2700000, 2);


-- ---------------------------------------------------------------------
-- CONTRATO 
-- id_estado_contrato: 1=vigente 2=finalizado 3=incumplido
-- ---------------------------------------------------------------------
INSERT INTO `CONTRATO` (`id_contrato`, `id_propiedad`, `id_cliente`, `id_empleado`, `fecha_firma`, `id_estado_contrato`) values
-- Contratos de VENTA (id_contrato 1-15)
(1, 16, 1, 3, '2023-02-10', 2),
(2, 17, 2, 4, '2023-03-05', 2),
(3, 18, 3, 5, '2023-04-18', 1),
(4, 19, 4, 6, '2023-05-22', 2),
(5, 20, 5, 7, '2023-06-30', 2),
(6, 21, 6, 8, '2023-07-14', 2),
(7, 22, 7, 9, '2023-08-09', 1),
(8, 23, 8, 3, '2023-09-25', 2),
(9, 24, 9, 4, '2023-10-12', 2),
(10, 25, 10, 5, '2023-11-08', 1),
(11, 26, 11, 6, '2023-12-01', 2),
(12, 27, 12, 7, '2024-01-15', 2),
(13, 28, 13, 8, '2024-02-20', 2),
(14, 29, 14, 9, '2024-03-11', 1),
(15, 30, 15, 3, '2024-04-05', 2),
-- Contratos de ARRIENDO (id_contrato 16-30)
(16, 31, 1, 4, '2023-03-01', 1),
(17, 32, 2, 6, '2023-04-01', 1),
(18, 33, 3, 9, '2023-05-01', 1),
(19, 34, 4, 4, '2023-06-01', 2),
(20, 35, 5, 7, '2023-07-01', 1),
(21, 36, 6, 3, '2023-08-01', 1),
(22, 37, 7, 3, '2023-09-01', 2),
(23, 38, 8, 5, '2023-10-01', 1),
(24, 39, 9, 7, '2023-11-01', 1),
(25, 40, 10, 8, '2023-12-01', 3),
(26, 41, 11, 3, '2024-01-01', 1),
(27, 42, 12, 5, '2024-02-01', 1),
(28, 43, 13, 6, '2024-03-01', 1),
(29, 44, 14, 8, '2024-04-01', 1),
(30, 45, 15, 9, '2024-05-01', 1);

select id_propiedad
from propiedad
order by id_propiedad asc;


-- ---------------------------------------------------------------------
-- CONTRATO_VENTA
-- ---------------------------------------------------------------------
insert into contrato_venta (`id_contrato`, `valor_venta`, `fecha_escritura`, `porcentaje_comision`) values
(1, 320000000, '2023-02-28', 3.5),
(2, 450000000, '2023-03-20', 3.0),
(3, 280000000, '2023-05-02', 4.0),
(4, 520000000, '2023-06-05', 3.0),
(5, 190000000, '2023-07-15', 4.0),
(6, 260000000, '2023-07-30', 3.5),
(7, 480000000, '2023-08-25', 3.0),
(8, 300000000, '2023-10-10', 3.5),
(9, 550000000, '2023-10-30', 3.0),
(10, 270000000, '2023-11-25', 4.0),
(11, 210000000, '2023-12-18', 4.0),
(12, 470000000, '2024-02-01', 3.0),
(13, 250000000, '2024-03-05', 3.5),
(14, 230000000, '2024-03-28', 4.0),
(15, 500000000, '2024-04-22', 3.0);

-- ---------------------------------------------------------------------
-- CONTRATO_ARRIENDO 
-- ---------------------------------------------------------------------

insert into contrato_arriendo (`id_contrato`, `valor_arriendo`, `fecha_inicio`, `fecha_fin`, `dia_pago`) values
(16, 2500000, '2023-03-01', '2024-02-29', 5),
(17, 2800000, '2023-04-01', '2024-03-31', 5),
(18, 2600000, '2023-05-01', '2024-04-30', 10),
(19, 3000000, '2023-06-01', '2024-05-31', 1),
(20, 2450000, '2023-07-01', '2024-06-30', 5),
(21, 2700000, '2023-08-01', '2024-07-31', 15),
(22, 1800000, '2023-09-01', '2024-08-31', 5),
(23, 1600000, '2023-10-01', '2024-09-30', 10),
(24, 1400000, '2023-11-01', '2024-10-31', 1),
(25, 1500000, '2023-12-01', '2024-11-30', 5),
(26, 1700000, '2024-01-01', '2024-12-31', 5),
(27, 1550000, '2024-02-01', '2025-01-31', 10),
(28, 1450000, '2024-03-01', '2025-02-28', 5),
(29, 1500000, '2024-04-01', '2025-03-31', 1);

-- ---------------------------------------------------------------------
-- PAGO
-- id_metodo_pago: 1=efectivo 2=transferencia 3=tarjeta 4=cheque
-- id_estado_pago: 1=a tiempo 2=atrasado 3=parcial
-- ---------------------------------------------------------------------
INSERT INTO `PAGO` (`id_contrato`, `fecha_pago`, `valor_pagado`, `mes_pagado`, `id_metodo_pago`, `id_estado_pago`) VALUES
(16, '2023-04-05', 2500000, '2023-04', 2, 1),
(16, '2023-05-06', 2500000, '2023-05', 2, 2),
(17, '2023-05-05', 2800000, '2023-05', 1, 1),
(18, '2023-06-11', 2600000, '2023-06', 2, 2),
(19, '2023-07-01', 3000000, '2023-07', 2, 1),
(20, '2023-08-05', 2450000, '2023-08', 3, 1),
(21, '2023-09-16', 2700000, '2023-09', 2, 2),
(22, '2023-10-05', 1800000, '2023-10', 1, 1),
(23, '2023-11-10', 1600000, '2023-11', 2, 1),
(24, '2023-12-02', 1400000, '2023-12', 2, 1),
(25, '2024-01-06', 1000000, '2024-01', 1, 3),
(26, '2024-02-05', 1700000, '2024-02', 2, 1),
(27, '2024-03-11', 1550000, '2024-03', 4, 1),
(28, '2024-04-05', 1450000, '2024-04', 2, 1),
(29, '2024-05-02', 1500000, '2024-05', 3, 1);

-- ---------------------------------------------------------------------
-- HISTORIAL_ESTADO_PROPIEDAD  
-- ---------------------------------------------------------------------
INSERT INTO `HISTORIAL_ESTADO_PROPIEDAD` (`id_propiedad`, `id_empleado`, `estado_anterior`, `estado_nuevo`, `fecha_cambio`) VALUES
(16, 3, 'disponible', 'vendida', '2023-02-28 10:15:00'),
(17, 4, 'disponible', 'arrendada', '2023-03-01 09:00:00'),
(18, 1, 'disponible', 'disponible', '2023-01-10 08:30:00'),
(19, 6, 'disponible', 'arrendada', '2023-04-01 11:20:00'),
(20, 7, 'disponible', 'disponible', '2023-01-15 14:00:00'),
(21, 8, 'disponible', 'vendida', '2023-07-30 16:45:00'),
(22, 9, 'disponible', 'arrendada', '2023-05-01 10:00:00'),
(23, 1, 'arrendada', 'disponible', '2023-12-31 09:30:00'),
(24, 4, 'disponible', 'arrendada', '2023-06-01 08:45:00'),
(25, 5, 'disponible', 'mantenimiento', '2024-01-05 13:10:00'),
(26, 6, 'disponible', 'disponible', '2023-01-20 09:15:00'),
(27, 2, 'disponible', 'arrendada', '2023-07-01 10:30:00'),
(28, 8, 'disponible', 'vendida', '2024-03-05 15:00:00'),
(29, 9, 'disponible', 'disponible', '2023-02-01 08:00:00'),
(30, 1, 'disponible', 'arrendada', '2023-08-01 09:50:00');
