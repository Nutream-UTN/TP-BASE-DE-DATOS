# Decisiones de diseño

## Resumen de la primera entrega

Para esta etapa se analizó la información disponible de la tabla maestra y las reglas de negocio del enunciado para diseñar el modelo de datos transaccional de la bicicletería. El DER organiza los datos de ubicación, personas, catálogos, productos, bicicletas, repuestos y las operaciones de venta, compra, alquiler y reparación, relacionados mediante claves primarias y foráneas.

El diseño incorpora entidades de detalle para ventas, compras y reparaciones, y documenta las principales decisiones tomadas, incluida la forma de calcular el subtotal de compra, que no está presente en la tabla maestra. `diagrama.puml` contiene la fuente del modelo y `DER.png` su representación visual.

A continuación se justifican los principales criterios de organización y relación aplicados al DER.

## Organización de los datos

- **Catálogos:** la tabla maestra reúne los datos en una estructura desnormalizada y no contiene tablas independientes para estos catálogos. Se incorporaron entidades para formas de pago, tipos de producto, marcas, categorías y estados. Así se evita repetir sus descripciones en las operaciones y se las puede referenciar mediante claves foráneas.
- **Localidad:** se modela como una entidad compartida por locales, clientes, empleados y proveedores. Esto permite asociar cada registro con una localidad y una provincia sin repetir esos datos en cada entidad.
- **Modelo de bicicleta:** `ModeloBicicleta` concentra los atributos comunes de un modelo —marca, categoría, rodado, cuadro y color— y puede asociarse a bicicletas para la venta, bicicletas de alquiler y reparaciones. De este modo, esos datos descriptivos se mantienen en un solo lugar.
- **Producto, bicicleta para la venta y accesorio:** `Producto` contiene los datos comunes de los productos comercializados, como código, nombre, descripción, precio y tipo. `BicicletaVenta` y `Accesorio` separan los atributos propios de cada clase y usan el código del producto como clave primaria y foránea. Esto evita duplicar los datos comunes y vincula cada especialización con su producto.
- **Cliente y empleado:** ambas entidades podrían compartir una entidad `Persona`, de la que dependieran `Cliente` y `Empleado`. Se mantienen separadas para simplificar la migración desde la tabla maestra y conservar una correspondencia directa con los roles que intervienen en las operaciones.

## Operaciones

- **DetalleVenta:** resuelve la relación muchos a muchos entre una venta y los productos vendidos: una venta puede incluir varios productos, y un producto puede aparecer en distintas ventas. La entidad también registra la cantidad y el precio unitario correspondiente a cada renglón.
- **DetalleCompra:** separa los productos comprados de los datos generales de la compra. Permite registrar varios productos por compra y conservar para cada renglón su cantidad y precio unitario de compra.
- **Bicicleta de alquiler:** se representa cada bicicleta disponible para alquilar mediante su número de serie. Se mantiene separada del catálogo de bicicletas para la venta porque el alquiler registra unidades físicas, con estado y tarifas por hora y por día.
- **Repuesto:** representa un tipo de repuesto, no una unidad física particular. Por eso, el mismo repuesto puede utilizarse en distintas reparaciones. La relación muchos a muchos entre `Reparacion` y `Repuesto` se resuelve mediante `DetalleReparacion`, donde se registran la cantidad y el precio unitario del repuesto utilizado.
- **Estados:** los estados de reparaciones, alquileres y bicicletas de alquiler se modelan en catálogos separados. Cada proceso conserva así sus propios valores de estado y puede referenciarlos mediante una clave foránea.

## Importes y datos de origen

- **Subtotal en DetalleVenta:** se conserva el subtotal registrado en la tabla maestra para cada producto vendido, junto con la cantidad y el precio unitario del renglón.
- **Subtotal en DetalleCompra:** no se almacena porque la tabla maestra no contiene el campo `Detalle_Compra_Subtotal_Prod_Compra`. Se calcula multiplicando la cantidad comprada por el precio unitario.