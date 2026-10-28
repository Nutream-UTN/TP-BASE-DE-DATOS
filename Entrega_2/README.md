# TP Base de Datos — Entrega 2: Modelo Relacional y Migración
**Facultad Regional Buenos Aires (UTN)**  
**Gestión de Datos / Base de Datos — 2° Cuatrimestre 2026**

---

## Información del Grupo
* **Grupo:** 38
* **Nombre de grupo / Esquema:** `NUTREAM`
* **Curso:** <CURSO>

### Integrantes:
* **Juliano, Tomás Rubén** — Legajo: 2150414 — *Email:* `tjuliano@frba.utn.edu.ar` (Responsable de grupo)
* **Candal, Nicolas** — Legajo: 2151250 — *Email:* `ncandal@frba.utn.edu.ar`
* **Rivas, Tiziano** — Legajo: 2226431 — *Email:* `trivas@frba.utn.edu.ar`
* **Moreno, Rocco** — Legajo: 2139133 — *Email:* `rmorenocicero@frba.utn.edu.ar`

---

## Alcance de la Entrega 2

Esta segunda entrega implementa el modelo transaccional normalizado a partir del diseño validado en la Entrega 1 y realiza la migración completa de los datos provistos en la tabla maestra (`gd_esquema.Maestra`).

### Requisitos y entregables de la etapa:
1. **`script_creacion_inicial.sql`:**
   * Creación del esquema `[NUTREAM]`.
   * Creación de todas las tablas relacionales con sus claves primarias, foráneas, tipos de datos coherentes con la tabla maestra, constraints e índices.
   * Procedimientos almacenados (Stored Procedures) para la migración de datos desde `gd_esquema.Maestra`.
   * Ejecución ordenada y limpia en una única pasada, sin errores ni advertencias (máx. 10 minutos).
2. **`diagrama.puml` / `DER.png` (o `DER.jpg`):**
   * Diagrama Entidad-Relación transaccional corregido y actualizado.
3. **`Estrategia.md` / `Estrategia.pdf`:**
   * Documento con carátula e índice donde se justifican las decisiones de diseño, la resolución de inconsistencias de la tabla maestra y el DER embebido.
4. **`Readme.txt`:**
   * Archivo plano con los datos del grupo y curso según formato requerido por la cátedra para el paquete final `.zip123`.

---

## Decisiones de Diseño y Organización de los Datos

### Organización de los datos
- **Catálogos:** La tabla maestra reúne los datos en una estructura desnormalizada y no contiene tablas independientes para estos catálogos. Se incorporaron entidades para formas de pago, tipos de producto, marcas, categorías y estados. Así se evita repetir sus descripciones en las operaciones y se las puede referenciar mediante claves foráneas.
- **Localidad:** Se modela como una entidad compartida por locales, clientes, empleados y proveedores. Esto permite asociar cada registro con una localidad y una provincia sin repetir esos datos en cada entidad.
- **Modelo de bicicleta:** `ModeloBicicleta` concentra los atributos comunes de un modelo —marca, categoría, rodado, cuadro y color— y puede asociarse a bicicletas para la venta, bicicletas de alquiler y reparaciones. De este modo, esos datos descriptivos se mantienen en un solo lugar.
- **Producto, bicicleta para la venta y accesorio:** `Producto` contiene los datos comunes de los productos comercializados, como código, nombre, descripción, precio y tipo. `BicicletaVenta` y `Accesorio` separan los atributos propios de cada clase y usan el código del producto como clave primaria y foránea. Esto evita duplicar los datos comunes y vincula cada especialización con su producto.
- **Cliente y empleado:** Ambas entidades podrían compartir una entidad `Persona`, de la que dependieran `Cliente` y `Empleado`. Se mantienen separadas para simplificar la migración desde la tabla maestra y conservar una correspondencia directa con los roles que intervienen en las operaciones.

### Operaciones
- **DetalleVenta:** Resuelve la relación muchos a muchos entre una venta y los productos vendidos: una venta puede incluir varios productos, y un producto puede aparecer en distintas ventas. La entidad también registra la cantidad y el precio unitario correspondiente a cada renglón.
- **DetalleCompra:** Separa los productos comprados de los datos generales de la compra. Permite registrar varios productos por compra y conservar para cada renglón su cantidad y precio unitario de compra.
- **Bicicleta de alquiler:** Se representa cada bicicleta disponible para alquilar mediante su número de serie y se vincula con el local propietario de la flota. Se mantiene separada del catálogo de bicicletas para la venta porque el alquiler registra unidades físicas, con estado y tarifas por hora y por día.
- **Repuesto:** Representa un tipo de repuesto, no una unidad física particular. Por eso, el mismo repuesto puede utilizarse en distintas reparaciones. La relación muchos a muchos entre `Reparacion` y `Repuesto` se resuelve mediante `DetalleReparacion`, donde se registran la cantidad y el precio unitario del repuesto utilizado.
- **Estados:** Los estados de reparaciones, alquileres y bicicletas de alquiler se modelan en catálogos separados. Cada proceso conserva así sus propios valores de estado y puede referenciarlos mediante una clave foránea.

### Importes y datos de origen
- **Subtotal en DetalleVenta:** Se conserva el subtotal registrado en la tabla maestra para cada producto vendido, junto con la cantidad y el precio unitario del renglón.
- **Subtotal en DetalleCompra:** No se almacena porque la tabla maestra no contiene el campo `Detalle_Compra_Subtotal_Prod_Compra`. Se calcula multiplicando la cantidad comprada por el precio unitario.

