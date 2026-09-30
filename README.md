# TP de Base de Datos: Gestión de Bicicletería

Este repositorio corresponde al Trabajo Práctico de Base de Datos de UTN FRBA para el segundo cuatrimestre de 2026. El enunciado propone diseñar e implementar un sistema para una bicicletería con varios locales, partiendo de una base provista por la cátedra cuya información operativa está concentrada en la tabla maestra.

El trabajo contempla dos modelos relacionados: uno transaccional, para registrar las operaciones del negocio, y otro de Inteligencia de Negocios (BI), para analizar sus resultados y facilitar la toma de decisiones.

## Alcance funcional

El sistema debe representar cuatro operaciones principales:

- **Ventas:** cada venta registra cliente, empleado, fecha y hora, forma de pago e importe total. El detalle permite vender bicicletas y accesorios, con cantidad, precio unitario y subtotal por producto.
- **Alquileres:** cada local administra su propia flota de bicicletas, identificadas por número de serie y separadas de las bicicletas a la venta. Se registran fechas de inicio y devolución, estado, forma de pago e importe; las tarifas pueden ser por hora o por día y una bicicleta no puede alquilarse a dos clientes simultáneamente.
- **Reparaciones:** se registra la bicicleta y el cliente, el empleado que la atiende, las fechas estimadas y reales, el diagnóstico, el estado y los importes de mano de obra y repuestos. Una reparación puede utilizar varios repuestos.
- **Compras:** cada local registra compras a proveedores, con el empleado responsable, fecha e importe total. El detalle identifica los productos, las cantidades y los precios unitarios de compra.

## Etapas y entregables

Las fechas que siguen corresponden al enunciado versión 1.0, actualizado el 3 de septiembre de 2026.

| Etapa | Entregables principales | Fecha indicada |
|---|---|---|
| DER transaccional | Diagrama relacional legible, en formato de imagen y con entidades, atributos y relaciones | 1 de octubre de 2026, hasta las 12:00 (Buenos Aires) |
| Modelo relacional y migración | Script único para crear y poblar el modelo relacional, DER corregido y documento de estrategia | 30 de octubre de 2026, hasta las 12:00 (Buenos Aires) |
| Modelo de BI | DER transaccional corregido, script relacional actualizado, DER de BI, script de creación y carga de BI y estrategia actualizada | 25 de noviembre de 2026, hasta las 12:00 (Buenos Aires) |
| Fecha final de recepción | Último día indicado para recibir el TP | 14 de diciembre de 2026 |

La primera entrega consiste solamente en el DER transaccional. El enunciado contempla dos instancias de reentrega en total para las etapas posteriores; no hay una reentrega separada del DER.

## Modelo transaccional

Se debe analizar y normalizar la información de la tabla maestra, definir las tablas necesarias y relacionarlas mediante claves primarias y foráneas. También se deben incluir las restricciones, los triggers y los índices que sean necesarios para el modelo y su rendimiento.

La migración debe cargar la totalidad de los datos de la tabla maestra mediante procedimientos almacenados. Se entrega en un único script T-SQL llamado `script_creacion_inicial.sql`, que debe crear los objetos en el orden correcto y ejecutarse de principio a fin sin errores ni advertencias. Las inconsistencias de los datos de origen deben documentarse y controlarse sin modificar la tabla maestra ni inventar información o causas.

## Modelo de Inteligencia de Negocios

El modelo de BI se crea en la misma base de datos que el modelo transaccional; el enunciado no permite crear una base de datos separada para BI. Sus tablas deben llevar el prefijo `BI_` y sus cargas deben partir de los datos migrados al modelo transaccional. El script único `script_creacion_BI.sql` debe crear y poblar el modelo, además de crear las vistas que resuelvan las consultas de negocio.

Como mínimo, el modelo debe contemplar dimensiones de tiempo (año, trimestre y mes), rango etario del cliente, tipo de producto, local, categoría de bicicletas, categoría de repuestos y tipo de ingreso por reparaciones (mano de obra o repuestos).

Las vistas deben permitir obtener estos indicadores:

1. Facturación mensual de ventas por local.
2. Ticket promedio mensual por tipo de producto y rango etario del cliente.
3. Porcentaje trimestral de ventas por tipo de producto y local.
4. Promedio mensual de horas de alquiler por local.
5. Cinco categorías de bicicletas más alquiladas por año.
6. Desvío promedio, en días, entre la fecha estimada y la fecha real de entrega de reparaciones, por local y trimestre.
7. Ranking mensual de categorías de repuestos más utilizadas.
8. Porcentaje trimestral de facturación de reparaciones por mano de obra y repuestos.
9. Promedio trimestral de unidades compradas por tipo de producto.
10. Importe mensual de compras por local.
11. Facturación mensual total del negocio por local, sumando ventas, alquileres y reparaciones.

## Implementación y condiciones técnicas

- El motor requerido es Microsoft SQL Server 2022; el enunciado admite las ediciones Express y Full.
- Los scripts deben estar escritos en T-SQL y contener todo lo necesario para crear y cargar cada modelo. La migración no puede depender de herramientas auxiliares ni de aplicaciones personalizadas.
- Todos los objetos nuevos (tablas, procedimientos almacenados, vistas, triggers y demás) deben pertenecer a un esquema propio del grupo, escrito en mayúsculas y con guiones bajos en lugar de espacios.
- Los scripts se prueban sobre una base limpia. Cada uno debe poder ejecutarse una sola vez, en orden, sin errores ni advertencias y dentro del máximo de diez minutos indicado por el enunciado.
- Se deben considerar la calidad del código SQL y el rendimiento de las consultas, las vistas, los procedimientos y los índices.

## Formato general de entrega

El paquete final debe seguir la estructura indicada por la cátedra e incluir los diagramas relacionales y de BI como imágenes, los scripts SQL dentro de `/data`, un `Readme.txt` con los datos del grupo y un `Estrategia.pdf` con carátula, índice, decisiones, supuestos y ambos DER. El envío es grupal y el enunciado establece un tamaño máximo de 20 MB para el archivo adjunto.

## Contenido actual del repositorio

- [`Entrega_1/diagrama.puml`](Entrega_1/diagrama.puml): fuente editable del DER transaccional.
- [`Entrega_1/DER.png`](Entrega_1/DER.png): representación visual del DER.
- [`Entrega_1/README.md`](Entrega_1/README.md): resumen de la primera entrega y justificaciones del diseño.
- [`Entrega_1/Decisiones de diseño.pdf`](Entrega_1/Decisiones%20de%20dise%C3%B1o.pdf): documento PDF de decisiones de diseño.

Este README resume el alcance general solicitado por el enunciado; el estado de los archivos del repositorio se describe en la sección anterior.