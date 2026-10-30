# Decisiones de diseño

## Modelo transaccional de gestión de bicicletería — Entregas 1 y 2

**Universidad Tecnológica Nacional — Facultad Regional Buenos Aires**  
**Asignatura:** Base de Datos / Gestión de Datos  
**Curso:** K3522 · Segundo cuatrimestre 2026  
**Grupo:** 38 · **Esquema:** `NUTREAM`  
**Integrantes:** Tomás Rubén Juliano · Nicolás Candal · Tiziano Rivas · Rocco Moreno

Este documento reúne las decisiones del DER presentado en la primera entrega y las precisiones aplicadas al modelo relacional y su migración en la segunda.

## Índice

1. [Alcance y objetivos](#1-alcance-y-objetivos)
2. [Organización y normalización](#2-organización-y-normalización)
3. [Productos, bicicletas y repuestos](#3-productos-bicicletas-y-repuestos)
4. [Claves y resolución de duplicados](#4-claves-y-resolución-de-duplicados)
5. [Operaciones e importes](#5-operaciones-e-importes)
6. [Tipos y valores nulos](#6-tipos-y-valores-nulos)
7. [Estrategia de migración y ejecución](#7-estrategia-de-migración-y-ejecución)
8. [Resumen de la migración](#8-resumen-de-la-migración)

## 1. Alcance y objetivos

La primera entrega definió el DER transaccional a partir de las reglas del negocio y de la estructura desnormalizada de `[gd_esquema].[Maestra]`. La segunda normalizó ese diseño, corrigió las relaciones observadas durante la revisión docente e implementó la creación y migración en T-SQL dentro del esquema `[NUTREAM]`.

La tabla maestra contiene 291.899 filas y 89 columnas. El modelo separa ubicación, personas, catálogos, productos y las cuatro operaciones del negocio: ventas, compras, alquileres y reparaciones. El objetivo es conservar la información disponible y evitar agregar relaciones o valores que la fuente no respalde.

El esquema `NUTREAM` se crea en la misma base `GD2C_2026`, separado del esquema de origen. La tabla maestra se consulta para la carga y permanece sin modificaciones.

## 2. Organización y normalización

- **Catálogos.** Formas de pago, tipos de producto, marcas, categorías y estados se almacenan en tablas independientes. Sus claves numéricas evitan repetir descripciones en las operaciones y permiten referenciarlas con claves foráneas.
- **Localidad.** La combinación de localidad y provincia identifica cada registro geográfico. La tabla compartida reduce repeticiones en locales, clientes, empleados y proveedores.
- **Personas.** Cliente y Empleado se mantienen como entidades separadas. Aunque podrían compartir un supertipo Persona, sus atributos y roles son distintos; la separación simplifica las relaciones con las operaciones y la migración desde la tabla maestra.
- **Local y asignación laboral.** Ventas, compras, reparaciones y bicicletas de alquiler se vinculan con el local que participa o administra la operación. Empleado no tiene una asignación fija a un local: los datos de transacciones muestran actividad en varios locales, pero no prueban una sede laboral permanente.

La organización procura reducir redundancias y dependencias transitivas, y separar cabeceras, detalles y catálogos. Los atributos propios de cada proceso quedan en su entidad correspondiente.

## 3. Productos, bicicletas y repuestos

- **Producto y subtipos.** Producto reúne código, nombre, descripción, precio y tipo. BicicletaVenta y Accesorio agregan los atributos particulares de cada clase y usan `cod_producto` como clave primaria y foránea al supertipo.
- **ModeloBicicleta.** Concentra nombre, rodado, cuadro, color, marca y categoría. Se reutiliza desde bicicletas para la venta, bicicletas de alquiler y reparaciones. La combinación de esos atributos identifica el registro técnico; las búsquedas de migración comparan la combinación completa.
- **Bicicletas de alquiler.** Cada fila representa una unidad física identificada por número de serie, con modelo, estado, tarifas y local propietario. Se separa de BicicletaVenta, que representa un producto del catálogo comercial.
- **Repuesto.** Representa un tipo de pieza del catálogo del taller, no una unidad física individual. Sus usos en reparaciones se registran en DetalleReparacion.

Los estados de alquiler, bicicleta de alquiler y reparación se conservan en catálogos distintos. Aunque comparten la idea de “estado”, pertenecen a procesos diferentes y no tienen necesariamente los mismos valores ni reglas.

## 4. Claves y resolución de duplicados

- **Id de la tabla maestra.** No se migra como clave de las entidades nuevas: identifica filas de la fuente desnormalizada, no las entidades del modelo transaccional. Se usan las claves propias de cada entidad y las relaciones necesarias.
- **Claves subrogadas.** Los catálogos, clientes y empleados usan claves numéricas `IDENTITY`. En las operaciones se conservan los números de venta, compra, alquiler y reparación como claves. Los detalles tienen identificadores propios generados.
- **DNI de clientes.** El DNI no es único en los datos: hay 147.613 perfiles distintos y 147.487 DNIs diferentes. Por eso Cliente usa `cliente_id` como PK. La combinación DNI-email tiene 147.613 valores únicos en el CSV y se utiliza con un índice único para enlazar de forma unívoca las operaciones con el perfil migrado.
- **Renglones repetidos.** Una misma venta puede contener varias filas para el mismo código de producto. Una PK compuesta por venta y producto las fusionaría o impediría cargarlas; el ID propio de DetalleVenta preserva cada renglón de origen. DetalleCompra y DetalleReparacion también se modelan como entidades de detalle.
- **Identidad del modelo.** El nombre solo no se usa como restricción de unicidad. El script evita duplicados mediante una clave compuesta de modelo, rodado, cuadro, color, marca y categoría, y busca bicicletas con esos mismos atributos.

## 5. Operaciones e importes

- **Ventas.** Venta representa la cabecera; DetalleVenta relaciona la venta con los productos e incluye cantidad, precio unitario y subtotal de origen.
- **Compras.** Compra registra local, proveedor, empleado, fecha e importe total. DetalleCompra conserva producto, cantidad y precio unitario.
- **Alquileres.** Alquiler relaciona cliente, empleado, forma de pago, estado y una bicicleta física por su número de serie. La fecha de devolución real permite `NULL` en el diseño para contemplar alquileres aún abiertos.
- **Reparaciones.** Reparacion registra la bicicleta, el cliente, empleado, local, modelo, estado y fechas, diagnóstico e importes. No se relaciona directamente con Venta o Compra: son procesos distintos y la fuente no proporciona una clave que represente esa asociación.
- **Subtotal de compra.** No se almacena en DetalleCompra porque la tabla maestra no contiene ese atributo. Puede calcularse como cantidad × precio unitario cuando se consulta.

Se preservan los importes almacenados en la tabla maestra, incluso cuando las verificaciones aritméticas no coinciden exactamente. No se reemplazan los valores originales por subtotales o totales recalculados y no se atribuye una causa no demostrada a las diferencias.

| Comprobación sobre los datos de origen | Resultado observado |
|---|---|
| Subtotal de detalle de venta frente a cantidad × precio unitario | 91.240 renglones con diferencia; desvío máximo observado: 0,02. |
| Total de cabecera de venta frente a suma de subtotales almacenados | 16.522 de 43.500 ventas con diferencia; máximo: 0,02. |
| Total de compra frente a suma de cantidad × precio unitario | 36 de 36 compras con diferencia; máximo: 10,51. |
| Subtotal de detalle de reparación frente a cantidad × precio unitario | 27.749 renglones con diferencia. |
| Total de reparación frente a mano de obra + repuestos | 8.940 de 34.493 reparaciones con diferencia; máximo: 0,01. |

Las cantidades y diferencias se documentan como observaciones del conjunto exportado. Se conservaron los valores de origen para evitar pérdida o alteración de información.

## 6. Tipos y valores nulos

El modelo relacional respeta los tipos indicados para la tabla maestra: `VARCHAR(255)` para cadenas, `NUMERIC(38,2)` para importes, `INT` para cantidades y números operativos, y `DATETIME2(6)` para fechas y marcas temporales. La precisión 6 conserva los seis dígitos fraccionarios de las fechas de origen.

El CSV contiene la palabra `NULL` en campos que no corresponden a la operación de esa fila, porque la tabla maestra combina varios procesos. La auditoría contó nulos dentro de cada conjunto aplicable y no encontró faltantes en los campos revisados. Las fechas de devolución real y entrega real se permiten como `NULL` en el modelo por su significado operativo, aunque el conjunto exportado actual tenga valores en esas columnas.

## 7. Estrategia de migración y ejecución

- **Esquema propio.** Tablas y procedimientos se crean bajo `[NUTREAM]`, manteniendo separado el modelo transaccional de `[gd_esquema].[Maestra]`.
- **Reejecución.** El script elimina condicionalmente los procedimientos y tablas propios de NUTREAM en orden inverso a sus dependencias y luego los reconstruye. Cada corrida reemplaza el contenido de NUTREAM y vuelve a migrar los datos; no agrega duplicados acumulativos.
- **Carga atómica.** Los procedimientos se ejecutan en una transacción con `TRY/CATCH`: si una migración falla, se revierte la carga transaccional y se informa el error.
- **Carga por conjuntos.** La migración usa `INSERT ... SELECT` y consultas `DISTINCT` donde corresponde, en lugar de procesar fila por fila. Las cadenas se recortan con `LTRIM`/`RTRIM` para emparejar claves textuales.
- **Índices.** Se incluyen restricciones e índices para las búsquedas de claves y diecisiete índices no agrupados sobre claves foráneas de las operaciones y sus detalles.

En la ejecución registrada por el grupo el 29/10/2026, el script completó la migración de los 19 pasos y creó los índices sin errores. El tiempo total informado fue de 8,36 segundos.

## 8. Resumen de la migración

| Grupo de entidades | Filas migradas |
|---|---|
| Localidades / locales | 480 localidades; 5 locales |
| Clientes / empleados / proveedores | 147.613 clientes; 25 empleados; 5 proveedores |
| Catálogo de productos y flota | 12 modelos; 18 productos (8 bicicletas y 10 accesorios); 80 bicicletas de alquiler; 10 repuestos |
| Ventas | 43.500 cabeceras; 152.418 detalles |
| Compras | 36 cabeceras; 648 detalles |
| Alquileres | 69.620 alquileres |
| Reparaciones | 34.493 cabeceras; 69.213 detalles |

Las filas operativas de origen quedan representadas mediante 152.418 renglones de venta, 648 renglones de compra, 69.620 alquileres y 69.213 renglones de reparación; juntos totalizan 291.899 filas de la tabla maestra.

---

*Documento de estrategia del modelo transaccional. Las decisiones aquí expuestas describen el diseño de las entregas 1 y 2; no incluyen el futuro modelo de Inteligencia de Negocios.*
