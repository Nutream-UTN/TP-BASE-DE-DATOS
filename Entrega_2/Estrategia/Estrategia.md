# Decisiones de diseño

## Modelo transaccional de gestión de bicicletería — Entregas 1 y 2

**Universidad Tecnológica Nacional — Facultad Regional Buenos Aires**  
**Asignatura:** Base de Datos / Gestión de Datos  
**Curso:** K3522 · Segundo cuatrimestre 2026  
**Grupo:** 38 · **Esquema:** `NUTREAM`  
**Integrantes:** Tomás Rubén Juliano · Nicolás Candal · Tiziano Rivas · Rocco Moreno

Acá explicamos las decisiones detrás del DER de la primera entrega y los ajustes que hicimos en la segunda, al pasar al modelo relacional y migrar los datos.

## Índice

1. [Alcance y objetivos](#1-alcance-y-objetivos)
2. [Organización y normalización](#2-organización-y-normalización)
3. [Productos, bicicletas y repuestos](#3-productos-bicicletas-y-repuestos)
4. [Claves y resolución de duplicados](#4-claves-y-resolución-de-duplicados)
5. [Operaciones e importes](#5-operaciones-e-importes)
6. [Tipos y valores nulos](#6-tipos-y-valores-nulos)
7. [Estrategia de migración y ejecución](#7-estrategia-de-migración-y-ejecución)

## 1. Alcance y objetivos

En la primera entrega armamos el DER transaccional a partir de las reglas del negocio y de la tabla desnormalizada `[gd_esquema].[Maestra]`. En la segunda lo normalizamos, corregimos las relaciones que nos marcaron en la revisión y escribimos en T-SQL la creación y la migración dentro del esquema `[NUTREAM]`.

La maestra tiene 291.899 filas y 89 columnas. El modelo la divide en ubicación, personas, catálogos, productos y las cuatro operaciones del negocio: ventas, compras, alquileres y reparaciones. El criterio general fue no perder datos y no inventar relaciones ni valores que la fuente no respalde.

`NUTREAM` vive en la misma base `GD2C_2026`, separado del esquema de origen. La maestra solo se lee durante la carga; no la modificamos.

## 2. Organización y normalización

- **Catálogos.** Formas de pago, tipos de producto, marcas, categorías y estados tienen su propia tabla con clave numérica. Así las operaciones guardan una FK en lugar de repetir la descripción.
- **Localidad.** Cada registro se identifica por el par localidad-provincia. Locales, clientes, empleados y proveedores apuntan a la misma tabla, lo que evita repetir esos datos en cada uno.
- **Personas.** Cliente y Empleado quedaron como entidades separadas. Se podría haber usado un supertipo Persona, pero tienen atributos y roles distintos, y separarlas simplifica tanto las relaciones con las operaciones como la migración.
- **Local y asignación laboral.** Ventas, compras, reparaciones y bicicletas de alquiler se vinculan con el local donde ocurre la operación o que administra la bicicleta. Empleado, en cambio, no tiene un local fijo: en las transacciones aparece trabajando en varios, y nada en los datos indica una sede permanente.

Separamos cabeceras, detalles y catálogos para eliminar redundancias y dependencias transitivas. Cada atributo quedó en la entidad del proceso al que pertenece.

## 3. Productos, bicicletas y repuestos

- **Producto y subtipos.** Producto tiene código, nombre, descripción, precio y tipo. BicicletaVenta y Accesorio agregan lo propio de cada clase y usan `cod_producto` como PK y como FK al supertipo.
- **ModeloBicicleta.** Agrupa nombre, rodado, cuadro, color, marca y categoría, y lo usan las bicicletas en venta, las de alquiler y las reparaciones. Lo que identifica un modelo es esa combinación completa, y así también lo buscamos durante la migración.
- **Bicicletas de alquiler.** Cada fila es una bicicleta física con número de serie, modelo, estado, tarifas y local. No tiene nada que ver con BicicletaVenta, que es un producto del catálogo comercial.
- **Repuesto.** Es un tipo de pieza del catálogo del taller, no una unidad física. Cada uso en una reparación se registra en DetalleReparacion.

Los estados de alquiler, de bicicleta de alquiler y de reparación están en tres catálogos distintos. Los tres son "estados", pero corresponden a procesos diferentes y no tienen por qué compartir valores ni reglas.

## 4. Claves y resolución de duplicados

- **Id de la maestra.** No lo usamos como clave en ninguna tabla nueva. Identifica filas de la fuente desnormalizada, no entidades del modelo; cada entidad tiene su propia clave.
- **Claves subrogadas.** Catálogos, clientes y empleados usan claves `IDENTITY`. En las operaciones mantuvimos como clave el número de venta, compra, alquiler o reparación que ya traía la fuente. Los detalles tienen un ID generado.
- **DNI de clientes.** El DNI no es único: hay 147.613 perfiles distintos y solo 147.487 DNIs diferentes. Por eso la PK de Cliente es `cliente_id`. El par DNI-email sí da 147.613 valores únicos en el CSV, así que le pusimos un índice único y lo usamos para asociar cada operación con su cliente al migrar.
- **Renglones repetidos.** Una venta puede tener varias filas con el mismo código de producto. Con una PK compuesta por venta y producto habría que fusionarlas o no se podrían cargar, así que DetalleVenta tiene su propio ID y conserva cada renglón tal como viene. DetalleCompra y DetalleReparacion siguen el mismo esquema.
- **Identidad del modelo.** El nombre del modelo solo no alcanza para garantizar unicidad. El script evita duplicados con una clave compuesta por modelo, rodado, cuadro, color, marca y categoría, y busca las bicicletas por esos mismos atributos.

## 5. Operaciones e importes

- **Ventas.** Venta es la cabecera. DetalleVenta la vincula con cada producto e incluye cantidad, precio unitario y el subtotal tal como viene en la fuente.
- **Compras.** Compra guarda local, proveedor, empleado, fecha e importe total. DetalleCompra guarda producto, cantidad y precio unitario.
- **Alquileres.** Alquiler se relaciona con cliente, empleado, forma de pago, estado y una bicicleta física por número de serie. La fecha de devolución real admite `NULL` para los alquileres que todavía no se cerraron.
- **Reparaciones.** Reparacion guarda la bicicleta, cliente, empleado, local, modelo, estado, fechas, diagnóstico e importes. No la relacionamos con Venta ni con Compra porque son procesos distintos y la fuente no tiene ninguna clave que las vincule.
- **Subtotal de compra.** DetalleCompra no lo guarda porque la maestra no tiene esa columna. Si hace falta, se calcula como cantidad × precio unitario.

Respetamos los importes de la maestra aunque las cuentas no cierren exactamente. No reemplazamos ningún valor por uno recalculado ni le atribuimos una causa a las diferencias, porque no tenemos forma de probarla.

## 6. Tipos y valores nulos

Usamos los mismos tipos que la maestra: `VARCHAR(255)` para texto, `NUMERIC(38,2)` para importes, `INT` para cantidades y números de operación, y `DATETIME2(6)` para fechas. La precisión 6 es para no perder los seis decimales de segundo que traen las fechas de origen.

## 7. Estrategia de migración y ejecución

- **Esquema propio.** Todas las tablas y procedimientos están en `[NUTREAM]`, separados de `[gd_esquema].[Maestra]`.
- **Reejecución.** El script borra, si existen, los procedimientos y tablas de NUTREAM en orden inverso a sus dependencias y después los vuelve a crear. Cada corrida reemplaza todo el contenido y migra de nuevo, así que no se acumulan duplicados.
- **Carga atómica.** Los procedimientos corren dentro de una transacción con `TRY/CATCH`: si algo falla, se deshace toda la carga y se informa el error.
- **Carga por conjuntos.** La migración usa `INSERT ... SELECT` y `DISTINCT` en lugar de recorrer fila por fila. Las cadenas se limpian con `LTRIM`/`RTRIM` para que las claves de texto coincidan.
- **Índices.** Además de las restricciones e índices para buscar claves durante la carga, creamos diecisiete índices no agrupados sobre las FK de las operaciones y sus detalles.
