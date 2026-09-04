# Sistema de Gestión Inmobiliaria — Base de Datos MySQL

Sistema de gestión inmobiliaria en MySQL: propiedades, clientes, contratos, pagos, funciones personalizadas, triggers de auditoría, roles y eventos programados.
Autoría: Nicolle Camila Piñeros Castañeda | Desarrolladora Full Stack Junior
---

## ▪️Diagrama Entidad-Relación

<img width="7140" height="3186" alt="DiseñoBD_Inmobiliaria" src="https://github.com/user-attachments/assets/da3d8853-0822-43b8-af1c-e633a3eefe5d" />

---

## 📂 Estructura del proyecto

Los scripts están pensados para ejecutarse **en este orden**:

| # | Archivo | Contenido |
|---|---|---|
| 1 | `BDeInserciones_inmobiliariaNova.sql` | Creación de las 15 tablas (catálogos + entidades) y datos de prueba |
| 2 | `Funciones_Inmobiliaria.sql` | 3 funciones personalizadas (UDFs) |
| 3 | `triggers_Inmobiliaria.sql` | Triggers de auditoría + tabla `AUDITORIA_CONTRATO` |
| 4 | `SeguridadyUsuarios_inmobiliaria.sql` | Roles y privilegios diferenciados |
| 5 | `OptimizacionyEvento_Inmobiliaria.sql` | Tabla de reportes + evento programado mensual |
| 6 | `Indices_Inmobiliaria.sql` | Índices de optimización |

> ⚠️ Los bloques que usan `DELIMITER $$` (funciones, triggers, evento) deben ejecutarse como **script completo**, no sentencia por sentencia — de lo contrario MySQL corta la sentencia en el primer `;` que encuentra dentro del cuerpo.

---

## ▪️ Decisiones de diseño

Estas son las decisiones más importantes que se tomaron durante el modelado, y el porqué detrás de cada una.

### 1. Catálogos separados en vez de texto libre o `ENUM`

Valores como el rol de un empleado, el tipo de propiedad, o el estado de un pago **no se guardan como texto suelto** en cada fila — se normalizaron en tablas de catálogo propias:

- `ROL`, `TIPO_PROPIEDAD`, `ESTADO_PROPIEDAD`, `ESTADO_CONTRATO`, `METODO_PAGO`, `ESTADO_PAGO`

Se evaluó usar `ENUM` directamente en la columna (más simple de insertar), pero se descartó porque **agregar un valor nuevo en el futuro** (ej. un cuarto tipo de propiedad) requeriría alterar la estructura de la tabla. Con catálogos aparte, basta un `INSERT` — sin tocar el esquema. Esto también da mejor trazabilidad: cada categoría vive en un solo lugar, sin riesgo de inconsistencias de escritura (`"Agente"` vs `"agente"`).

### 2. Especialización de `CONTRATO` en venta y arriendo

`CONTRATO_VENTA` y `CONTRATO_ARRIENDO` son tablas hijas de `CONTRATO`, con clave compartida (`id_contrato` es a la vez PK y FK). Se eligió este patrón porque venta y arriendo tienen atributos y reglas de negocio genuinamente distintos (fechas de vigencia y depósito vs. fecha de escritura y comisión), y mezclarlos en una sola tabla habría dejado columnas nulas según el tipo de contrato.

Por el mismo criterio se evaluó especializar también `PROPIEDAD` (en `CASA`/`APARTAMENTO`/`LOCAL`), pero se descartó: el nivel de detalle no era necesario para el proyecto, así que el tipo quedó como un simple atributo (`tipo_propiedad`) en vez de tablas separadas.

### 3. Valores calculados que **no** se almacenan

La comisión de una venta y la deuda pendiente de un arriendo **no son columnas** en ninguna tabla — se calculan al vuelo con funciones (`calcularComisionVentas`, `calcularDeudaPendiente`). Guardarlos como columna habría violado 3FN (son datos derivados de otros campos) y se habrían desactualizado cada vez que se registrara un nuevo pago.

### 4. Registro histórico "congelado"

En `HISTORIAL_ESTADO_PROPIEDAD`, los campos `estado_anterior` y `estado_nuevo` se guardan como **texto plano**, no como FK al catálogo `ESTADO_PROPIEDAD`. Es una excepción intencional: si el catálogo cambiara más adelante, el historial no debe reescribirse retroactivamente — es una foto del momento, no una referencia viva.

---

## Funciones personalizadas

| Función | Qué hace |
|---|---|
| `calcularComisionVentas(id_contrato)` | `valor_venta × (porcentaje_comision / 100)` |
| `calcularDeudaPendiente(id_contrato)` | Meses debidos desde `fecha_inicio` × valor mensual, menos lo ya pagado en `PAGO` |
| `propiedadesDisponiblesPorTipo(tipo)` | Cuenta propiedades de un tipo dado que estén en estado `disponible` |

```sql
SELECT calcularComisionVentas(3) AS comision;
SELECT calcularDeudaPendiente(16) AS deuda;
SELECT propiedadesDisponiblesPorTipo('apto') AS disponibles;
```

---

##  Triggers de auditoría

| Trigger | Se dispara en | Registra en |
|---|---|---|
| `trg_cambioEstadoPropiedad` | `UPDATE` en `PROPIEDAD`, solo si `id_estado` cambió | `HISTORIAL_ESTADO_PROPIEDAD` |
| `trg_contratoNuevo` | `INSERT` en `CONTRATO` | `AUDITORIA_CONTRATO` |

El empleado responsable del cambio de estado se toma de la variable de sesión `@id_empleado_actual` (debe fijarse antes del `UPDATE`); si no se define, queda registrado el administrador por defecto.

---

## Seguridad y roles

Se definieron 3 roles con privilegios diferenciados usando `CREATE ROLE` (MySQL 8+):

| Rol | Puede hacer |
|---|---|
| `rol_administrador` | Todo (`ALL PRIVILEGES`) |
| `rol_agente` | Gestiona propiedades y contratos; solo consulta clientes; sin acceso a pagos |
| `rol_contador` | Gestiona pagos; solo consulta contratos y propiedades |

Cada usuario de MySQL (uno por empleado, según `EMPLEADO.usuario_mysql`) recibe su rol correspondiente vía `GRANT` + `SET DEFAULT ROLE`.

---

##  Optimización

- Índices en columnas de filtro frecuente que no son FK (las FK ya se indexan automáticamente): fechas de pago, fecha de firma de contrato, ciudad de la propiedad.
- Verificación con `EXPLAIN` para confirmar que las consultas sí usan el índice esperado (columna `key` del resultado).

---

##  Evento programado

`ev_reportePagosPendientes` corre automáticamente **cada mes** y llena `REPORTE_PAGOS_PENDIENTES` con los contratos de arriendo que tienen deuda pendiente (`calcularDeudaPendiente(id_contrato) > 0`).

```sql
SET GLOBAL event_scheduler = ON;   -- necesario para que los eventos corran
SHOW EVENTS FROM inmobiliaria;     -- confirmar que quedó activo
```

---

##  Cómo ejecutar el proyecto

1. Crea la base de datos: `CREATE DATABASE inmobiliaria;`
2. Ejecuta los 6 scripts en el orden de la tabla de arriba, **como script completo** (`Alt + X` en DBeaver, o el equivalente en tu cliente).
3. Verifica que todo quedó creado:
   ```sql
   SHOW TABLES;
   SHOW FUNCTION STATUS WHERE Db = 'inmobiliaria';
   SHOW TRIGGERS FROM inmobiliaria;
   SHOW EVENTS FROM inmobiliaria;
   ```
