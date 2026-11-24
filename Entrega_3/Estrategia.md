# Estrategia del modelo de Inteligencia de Negocios

## Propósito

El modelo de BI organiza la información del sistema de la bicicletería para facilitar el análisis de los 11 indicadores solicitados. Se implementa dentro del esquema `NUTREAM`, a partir de los datos ya migrados al modelo transaccional. Los objetos del modelo llevan el prefijo `BI_`.

El script de BI crea las dimensiones y tablas de hechos, las carga desde el modelo transaccional y genera una vista para cada indicador. La ejecución vuelve a generar únicamente los objetos de BI; no modifica las tablas transaccionales ni la tabla maestra.

## Organización dimensional

El DER se divide en dimensiones y hechos. Las dimensiones aportan el contexto descriptivo para filtrar y agrupar los resultados, como el período, el local, el tipo de producto o una categoría. Las tablas de hechos registran eventos y medidas que se pueden contar, sumar o promediar.

La selección de tablas y atributos responde a las consultas necesarias para resolver los 11 indicadores. Una tabla puede participar en más de una vista, y una vista puede combinar resultados de distintos hechos. Las operaciones de cada hecho se agregan por separado antes de combinarse, para evitar duplicar importes o cantidades.

### Dimensiones

- **Tiempo:** contiene una fila por día y sus atributos de año, trimestre y mes. Esto permite agrupar los hechos en los períodos solicitados.
- **Local:** identifica el local asociado a cada operación y aporta su nombre, localidad y provincia. `local_key` es la clave del modelo BI y `local_id_origen` conserva la referencia al local transaccional.
- **Rango etario:** clasifica al cliente según su edad en la fecha de la venta.
- **Tipo de producto:** distingue las clases de productos vendidas o compradas.
- **Categoría de bicicleta:** permite comparar las bicicletas alquiladas por categoría.
- **Categoría de repuesto:** permite analizar qué categorías de repuestos se utilizan con mayor frecuencia.
- **Tipo de ingreso de reparación:** separa los importes de mano de obra y repuestos.

Los identificadores internos de las dimensiones mantienen las relaciones del modelo BI. Cuando corresponde, se conserva además el identificador del modelo transaccional para reconocer el origen de cada registro.

## Granularidad de los hechos

La granularidad define qué representa una fila de una tabla de hechos. Se estableció de acuerdo con las medidas que requiere cada análisis:

- **`BI_FactVenta`:** una fila por venta, con su importe total. Se utiliza para la facturación de ventas por período y local.
- **`BI_FactVentaTipoProducto`:** una fila por venta y tipo de producto. Si una venta incluye bicicletas y accesorios, tiene una fila para cada tipo. El importe registra la suma de los subtotales correspondientes a ese tipo dentro de la venta.
- **`BI_FactAlquiler`:** una fila por alquiler, con su importe, local y categoría de bicicleta. Las horas se calculan con la fecha de inicio y la fecha de devolución real.
- **`BI_FactReparacion`:** una fila por reparación entregada, con la diferencia en días entre la fecha estimada y la fecha real de entrega.
- **`BI_FactRepuestoUsado`:** una fila por detalle de repuesto incluido en una reparación, con la categoría del repuesto y las unidades utilizadas.
- **`BI_FactIngresoReparacion`:** una fila por reparación y tipo de ingreso. Cada reparación entregada tiene un registro para mano de obra y otro para repuestos.
- **`BI_FactCompra`:** una fila por compra, con el importe total y el local.
- **`BI_FactCompraTipoProducto`:** una fila por compra y tipo de producto. Las unidades de varios renglones del mismo tipo se agrupan dentro de esa fila.

## Cálculo de los indicadores

1. **Facturación mensual de ventas por local:** se suman los importes de `BI_FactVenta` por mes y local.
2. **Ticket promedio mensual por tipo de producto y rango etario:** se promedia el importe de ese tipo de producto dentro de cada venta, agrupado por mes, tipo y rango etario del cliente.
3. **Porcentaje trimestral de ventas por tipo de producto y local:** se suman los importes por tipo y se calcula qué proporción representan sobre las ventas del mismo trimestre y local.
4. **Promedio mensual de horas de alquiler por local:** se promedian las horas reales de los alquileres por mes y local.
5. **Cinco categorías de bicicletas más alquiladas por año:** se cuentan los alquileres por año y categoría, y se ordenan de mayor a menor.
6. **Desvío promedio de entrega de reparaciones por local y trimestre:** se promedia la diferencia en días entre la fecha estimada y la fecha real de entrega.
7. **Ranking mensual de categorías de repuestos más utilizadas:** se suman las unidades utilizadas por mes y categoría.
8. **Porcentaje trimestral de facturación de reparaciones por tipo de ingreso:** se compara el importe de mano de obra y repuestos con la facturación total de reparaciones del trimestre.
9. **Promedio trimestral de unidades compradas por tipo de producto:** se promedian las unidades de cada tipo por compra dentro del trimestre.
10. **Importe mensual de compras por local:** se suman los totales de compra por mes y local.
11. **Facturación mensual total por local:** se combinan los totales mensuales de ventas, alquileres y reparaciones.

## Supuestos de cálculo

### Rangos etarios

La consigna presenta límites que se superponen entre algunos rangos. Para que cada edad pertenezca a un único grupo, se interpretan así: **0 a 25 años, 26 a 35, 36 a 50 y 51 o más**. En el indicador de ventas se utiliza la edad que tenía el cliente en la fecha de la operación, no su edad actual.

### Períodos de imputación

- Las ventas se asignan al día de la venta y las compras al día de la compra.
- Los alquileres se asignan al mes de inicio. Las horas se calculan solo cuando existe una devolución real válida; si falta esa fecha, las horas quedan sin valor y no participan del promedio. El alquiler sí se conserva para los indicadores de cantidad y facturación.
- El desvío y los ingresos de reparación se asignan a la fecha de entrega real. Por ello, las reparaciones sin fecha de entrega real no participan de esos indicadores.
- El uso de repuestos se asigna al mes de ingreso de la reparación, ya que el modelo transaccional no registra una fecha individual para cada repuesto utilizado.

Los importes y cantidades se obtienen de las tablas transaccionales. No se generan datos para completar valores ausentes ni se alteran los registros de origen.
