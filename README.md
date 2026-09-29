## Decisiones de diseño

- **DetalleVenta:** entidad que resuelve la relación muchos a muchos entre una venta y los productos vendidos.
- **Catálogos:** aunque no están separados como tablas en `Maestra`, agregamos tablas para los catálogos y sus identificadores, con el objetivo de normalizar el modelo y facilitar las relaciones.
- **Cliente y Empleado:** podrían compartir una tabla `Persona`, de la que luego dependieran `Cliente` y `Empleado`. Sin embargo, decidimos mantenerlos separados para simplificar la migración.
- **Repuesto:** representa un tipo de repuesto, no una unidad física particular. Por eso, el mismo repuesto puede utilizarse en distintas reparaciones. La relación con `Reparacion` es muchos a muchos y se resuelve mediante `DetalleReparacion`.
- **Subtotal en DetalleCompra:** no lo almacenamos porque no está incluido en `Maestra`; se calcula multiplicando la cantidad comprada por el precio unitario.