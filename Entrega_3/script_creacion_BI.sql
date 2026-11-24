/* ============================================================================
   ENTREGA 3 - MODELO DE INTELIGENCIA DE NEGOCIOS
   Grupo / esquema: NUTREAM

   Requiere que script_creacion_inicial.sql ya se haya ejecutado en la base
   actual. Este script solo elimina y recrea objetos BI_ del esquema NUTREAM;
   no modifica las tablas transaccionales ni gd_esquema.Maestra.

   Las decisiones sobre bandas etarias, fechas de imputación y granos están
   documentadas junto a las cargas y vistas correspondientes.
   ============================================================================ */

SET NOCOUNT ON;
SET XACT_ABORT ON;

IF SCHEMA_ID(N'NUTREAM') IS NULL
    THROW 51000, 'No existe el esquema NUTREAM. Ejecute primero script_creacion_inicial.sql.', 1;

IF OBJECT_ID(N'NUTREAM.Venta', N'U') IS NULL
   OR OBJECT_ID(N'NUTREAM.Compra', N'U') IS NULL
   OR OBJECT_ID(N'NUTREAM.Alquiler', N'U') IS NULL
   OR OBJECT_ID(N'NUTREAM.Reparacion', N'U') IS NULL
   OR OBJECT_ID(N'NUTREAM.DetalleVenta', N'U') IS NULL
   OR OBJECT_ID(N'NUTREAM.DetalleCompra', N'U') IS NULL
   OR OBJECT_ID(N'NUTREAM.DetalleReparacion', N'U') IS NULL
    THROW 51001, 'Faltan tablas transaccionales requeridas. Ejecute primero script_creacion_inicial.sql.', 1;

BEGIN TRY
    BEGIN TRANSACTION;

    /* Elimina únicamente las vistas y tablas BI de una ejecución anterior. */
    PRINT '>> [1/26] Eliminando objetos BI de una ejecución anterior...';
    DROP VIEW IF EXISTS [NUTREAM].[BI_VistaIndicador11_FacturacionMensualTotal];
    DROP VIEW IF EXISTS [NUTREAM].[BI_VistaIndicador10_ComprasMensualesPorLocal];
    DROP VIEW IF EXISTS [NUTREAM].[BI_VistaIndicador09_PromedioUnidadesCompradas];
    DROP VIEW IF EXISTS [NUTREAM].[BI_VistaIndicador08_PorcentajeFacturacionReparaciones];
    DROP VIEW IF EXISTS [NUTREAM].[BI_VistaIndicador07_RankingRepuestosUsados];
    DROP VIEW IF EXISTS [NUTREAM].[BI_VistaIndicador06_DesvioEntregaReparaciones];
    DROP VIEW IF EXISTS [NUTREAM].[BI_VistaIndicador05_CincoCategoriasMasAlquiladas];
    DROP VIEW IF EXISTS [NUTREAM].[BI_VistaIndicador04_PromedioHorasAlquiler];
    DROP VIEW IF EXISTS [NUTREAM].[BI_VistaIndicador03_PorcentajeVentasPorTipoYLocal];
    DROP VIEW IF EXISTS [NUTREAM].[BI_VistaIndicador02_TicketPromedioPorTipoYEdad];
    DROP VIEW IF EXISTS [NUTREAM].[BI_VistaIndicador01_FacturacionVentasMensual];

    DROP TABLE IF EXISTS [NUTREAM].[BI_FactCompraTipoProducto];
    DROP TABLE IF EXISTS [NUTREAM].[BI_FactCompra];
    DROP TABLE IF EXISTS [NUTREAM].[BI_FactIngresoReparacion];
    DROP TABLE IF EXISTS [NUTREAM].[BI_FactRepuestoUsado];
    DROP TABLE IF EXISTS [NUTREAM].[BI_FactReparacion];
    DROP TABLE IF EXISTS [NUTREAM].[BI_FactAlquiler];
    DROP TABLE IF EXISTS [NUTREAM].[BI_FactVentaTipoProducto];
    DROP TABLE IF EXISTS [NUTREAM].[BI_FactVenta];
    DROP TABLE IF EXISTS [NUTREAM].[BI_DimTipoIngresoReparacion];
    DROP TABLE IF EXISTS [NUTREAM].[BI_DimCategoriaRepuesto];
    DROP TABLE IF EXISTS [NUTREAM].[BI_DimCategoriaBicicleta];
    DROP TABLE IF EXISTS [NUTREAM].[BI_DimTipoProducto];
    DROP TABLE IF EXISTS [NUTREAM].[BI_DimRangoEtario];
    DROP TABLE IF EXISTS [NUTREAM].[BI_DimLocal];
    DROP TABLE IF EXISTS [NUTREAM].[BI_DimTiempo];

    /* Dimensiones. Las claves de origen se conservan como atributos únicos. */
    PRINT '>> [2/26] Creando las dimensiones BI...';
    CREATE TABLE [NUTREAM].[BI_DimTiempo] (
        fecha_key INT NOT NULL,
        fecha DATE NOT NULL,
        anio INT NOT NULL,
        trimestre INT NOT NULL,
        mes INT NOT NULL,
        nombre_mes VARCHAR(20) NOT NULL,
        CONSTRAINT PK_BI_DimTiempo PRIMARY KEY (fecha_key),
        CONSTRAINT UQ_BI_DimTiempo_Fecha UNIQUE (fecha),
        CONSTRAINT CK_BI_DimTiempo_Trimestre CHECK (trimestre BETWEEN 1 AND 4),
        CONSTRAINT CK_BI_DimTiempo_Mes CHECK (mes BETWEEN 1 AND 12)
    );

    CREATE TABLE [NUTREAM].[BI_DimLocal] (
        local_key INT NOT NULL,
        local_id_origen INT NOT NULL,
        nombre_local VARCHAR(255) NOT NULL,
        localidad VARCHAR(255) NOT NULL,
        provincia VARCHAR(255) NOT NULL,
        CONSTRAINT PK_BI_DimLocal PRIMARY KEY (local_key),
        CONSTRAINT UQ_BI_DimLocal_Origen UNIQUE (local_id_origen)
    );

    CREATE TABLE [NUTREAM].[BI_DimRangoEtario] (
        rango_etario_key INT NOT NULL,
        nombre_rango VARCHAR(50) NOT NULL,
        edad_desde INT NOT NULL,
        edad_hasta INT NULL,
        CONSTRAINT PK_BI_DimRangoEtario PRIMARY KEY (rango_etario_key),
        CONSTRAINT UQ_BI_DimRangoEtario_Nombre UNIQUE (nombre_rango),
        CONSTRAINT CK_BI_DimRangoEtario_Limites CHECK
            (edad_hasta IS NULL OR edad_hasta >= edad_desde)
    );

    CREATE TABLE [NUTREAM].[BI_DimTipoProducto] (
        tipo_producto_key INT NOT NULL,
        tipo_producto_id_origen INT NOT NULL,
        nombre_tipo_producto VARCHAR(255) NOT NULL,
        CONSTRAINT PK_BI_DimTipoProducto PRIMARY KEY (tipo_producto_key),
        CONSTRAINT UQ_BI_DimTipoProducto_Origen UNIQUE (tipo_producto_id_origen)
    );

    CREATE TABLE [NUTREAM].[BI_DimCategoriaBicicleta] (
        categoria_bicicleta_key INT NOT NULL,
        categoria_bicicleta_id_origen INT NOT NULL,
        nombre_categoria VARCHAR(255) NOT NULL,
        CONSTRAINT PK_BI_DimCategoriaBicicleta PRIMARY KEY (categoria_bicicleta_key),
        CONSTRAINT UQ_BI_DimCategoriaBicicleta_Origen UNIQUE (categoria_bicicleta_id_origen)
    );

    CREATE TABLE [NUTREAM].[BI_DimCategoriaRepuesto] (
        categoria_repuesto_key INT NOT NULL,
        categoria_repuesto_id_origen INT NOT NULL,
        nombre_categoria VARCHAR(255) NOT NULL,
        CONSTRAINT PK_BI_DimCategoriaRepuesto PRIMARY KEY (categoria_repuesto_key),
        CONSTRAINT UQ_BI_DimCategoriaRepuesto_Origen UNIQUE (categoria_repuesto_id_origen)
    );

    CREATE TABLE [NUTREAM].[BI_DimTipoIngresoReparacion] (
        tipo_ingreso_key INT NOT NULL,
        nombre_tipo_ingreso VARCHAR(30) NOT NULL,
        CONSTRAINT PK_BI_DimTipoIngresoReparacion PRIMARY KEY (tipo_ingreso_key),
        CONSTRAINT UQ_BI_DimTipoIngresoReparacion_Nombre UNIQUE (nombre_tipo_ingreso)
    );

    /* Tablas de hechos y sus relaciones con las dimensiones. */
    PRINT '>> [3/26] Creando las tablas de hechos BI...';
    CREATE TABLE [NUTREAM].[BI_FactVenta] (
        nro_venta INT NOT NULL,
        fecha_venta_key INT NOT NULL,
        local_key INT NOT NULL,
        importe_total_venta NUMERIC(38,2) NOT NULL,
        cantidad_ventas INT NOT NULL,
        CONSTRAINT PK_BI_FactVenta PRIMARY KEY (nro_venta),
        CONSTRAINT FK_BI_FactVenta_Tiempo FOREIGN KEY (fecha_venta_key)
            REFERENCES [NUTREAM].[BI_DimTiempo](fecha_key),
        CONSTRAINT FK_BI_FactVenta_Local FOREIGN KEY (local_key)
            REFERENCES [NUTREAM].[BI_DimLocal](local_key)
    );

    CREATE TABLE [NUTREAM].[BI_FactVentaTipoProducto] (
        nro_venta INT NOT NULL,
        tipo_producto_key INT NOT NULL,
        fecha_venta_key INT NOT NULL,
        local_key INT NOT NULL,
        rango_etario_key INT NOT NULL,
        importe_tipo_producto_en_venta NUMERIC(38,2) NOT NULL,
        unidades_vendidas INT NOT NULL,
        CONSTRAINT PK_BI_FactVentaTipoProducto PRIMARY KEY (nro_venta, tipo_producto_key),
        CONSTRAINT FK_BI_FactVentaTipoProducto_Tipo FOREIGN KEY (tipo_producto_key)
            REFERENCES [NUTREAM].[BI_DimTipoProducto](tipo_producto_key),
        CONSTRAINT FK_BI_FactVentaTipoProducto_Tiempo FOREIGN KEY (fecha_venta_key)
            REFERENCES [NUTREAM].[BI_DimTiempo](fecha_key),
        CONSTRAINT FK_BI_FactVentaTipoProducto_Local FOREIGN KEY (local_key)
            REFERENCES [NUTREAM].[BI_DimLocal](local_key),
        CONSTRAINT FK_BI_FactVentaTipoProducto_Edad FOREIGN KEY (rango_etario_key)
            REFERENCES [NUTREAM].[BI_DimRangoEtario](rango_etario_key)
    );

    CREATE TABLE [NUTREAM].[BI_FactAlquiler] (
        nro_alquiler INT NOT NULL,
        fecha_inicio_key INT NOT NULL,
        local_key INT NOT NULL,
        categoria_bicicleta_key INT NOT NULL,
        horas_alquiler NUMERIC(10,2) NULL,
        importe_total_alquiler NUMERIC(38,2) NOT NULL,
        cantidad_alquileres INT NOT NULL,
        CONSTRAINT PK_BI_FactAlquiler PRIMARY KEY (nro_alquiler),
        CONSTRAINT FK_BI_FactAlquiler_Tiempo FOREIGN KEY (fecha_inicio_key)
            REFERENCES [NUTREAM].[BI_DimTiempo](fecha_key),
        CONSTRAINT FK_BI_FactAlquiler_Local FOREIGN KEY (local_key)
            REFERENCES [NUTREAM].[BI_DimLocal](local_key),
        CONSTRAINT FK_BI_FactAlquiler_Categoria FOREIGN KEY (categoria_bicicleta_key)
            REFERENCES [NUTREAM].[BI_DimCategoriaBicicleta](categoria_bicicleta_key)
    );

    CREATE TABLE [NUTREAM].[BI_FactReparacion] (
        nro_reparacion INT NOT NULL,
        fecha_entrega_real_key INT NOT NULL,
        local_key INT NOT NULL,
        desvio_entrega_dias INT NOT NULL,
        CONSTRAINT PK_BI_FactReparacion PRIMARY KEY (nro_reparacion),
        CONSTRAINT FK_BI_FactReparacion_Tiempo FOREIGN KEY (fecha_entrega_real_key)
            REFERENCES [NUTREAM].[BI_DimTiempo](fecha_key),
        CONSTRAINT FK_BI_FactReparacion_Local FOREIGN KEY (local_key)
            REFERENCES [NUTREAM].[BI_DimLocal](local_key)
    );

    CREATE TABLE [NUTREAM].[BI_FactRepuestoUsado] (
        detalle_reparacion_id INT NOT NULL,
        fecha_reparacion_key INT NOT NULL,
        local_key INT NOT NULL,
        categoria_repuesto_key INT NOT NULL,
        unidades_utilizadas INT NOT NULL,
        CONSTRAINT PK_BI_FactRepuestoUsado PRIMARY KEY (detalle_reparacion_id),
        CONSTRAINT FK_BI_FactRepuestoUsado_Tiempo FOREIGN KEY (fecha_reparacion_key)
            REFERENCES [NUTREAM].[BI_DimTiempo](fecha_key),
        CONSTRAINT FK_BI_FactRepuestoUsado_Local FOREIGN KEY (local_key)
            REFERENCES [NUTREAM].[BI_DimLocal](local_key),
        CONSTRAINT FK_BI_FactRepuestoUsado_Categoria FOREIGN KEY (categoria_repuesto_key)
            REFERENCES [NUTREAM].[BI_DimCategoriaRepuesto](categoria_repuesto_key)
    );

    CREATE TABLE [NUTREAM].[BI_FactIngresoReparacion] (
        nro_reparacion INT NOT NULL,
        tipo_ingreso_key INT NOT NULL,
        fecha_entrega_real_key INT NOT NULL,
        local_key INT NOT NULL,
        importe_ingreso NUMERIC(38,2) NOT NULL,
        CONSTRAINT PK_BI_FactIngresoReparacion PRIMARY KEY (nro_reparacion, tipo_ingreso_key),
        CONSTRAINT FK_BI_FactIngresoReparacion_Tipo FOREIGN KEY (tipo_ingreso_key)
            REFERENCES [NUTREAM].[BI_DimTipoIngresoReparacion](tipo_ingreso_key),
        CONSTRAINT FK_BI_FactIngresoReparacion_Tiempo FOREIGN KEY (fecha_entrega_real_key)
            REFERENCES [NUTREAM].[BI_DimTiempo](fecha_key),
        CONSTRAINT FK_BI_FactIngresoReparacion_Local FOREIGN KEY (local_key)
            REFERENCES [NUTREAM].[BI_DimLocal](local_key)
    );

    CREATE TABLE [NUTREAM].[BI_FactCompra] (
        nro_compra INT NOT NULL,
        fecha_compra_key INT NOT NULL,
        local_key INT NOT NULL,
        importe_total_compra NUMERIC(38,2) NOT NULL,
        cantidad_compras INT NOT NULL,
        CONSTRAINT PK_BI_FactCompra PRIMARY KEY (nro_compra),
        CONSTRAINT FK_BI_FactCompra_Tiempo FOREIGN KEY (fecha_compra_key)
            REFERENCES [NUTREAM].[BI_DimTiempo](fecha_key),
        CONSTRAINT FK_BI_FactCompra_Local FOREIGN KEY (local_key)
            REFERENCES [NUTREAM].[BI_DimLocal](local_key)
    );

    CREATE TABLE [NUTREAM].[BI_FactCompraTipoProducto] (
        nro_compra INT NOT NULL,
        tipo_producto_key INT NOT NULL,
        fecha_compra_key INT NOT NULL,
        local_key INT NOT NULL,
        unidades_compradas INT NOT NULL,
        CONSTRAINT PK_BI_FactCompraTipoProducto PRIMARY KEY (nro_compra, tipo_producto_key),
        CONSTRAINT FK_BI_FactCompraTipoProducto_Tipo FOREIGN KEY (tipo_producto_key)
            REFERENCES [NUTREAM].[BI_DimTipoProducto](tipo_producto_key),
        CONSTRAINT FK_BI_FactCompraTipoProducto_Tiempo FOREIGN KEY (fecha_compra_key)
            REFERENCES [NUTREAM].[BI_DimTiempo](fecha_key),
        CONSTRAINT FK_BI_FactCompraTipoProducto_Local FOREIGN KEY (local_key)
            REFERENCES [NUTREAM].[BI_DimLocal](local_key)
    );

    /* Cargas de dimensiones. Claves sustitutas deterministas al regenerar. */
    PRINT '>> [4/26] Cargando dimensiones de locales, productos y categorías...';
    INSERT INTO [NUTREAM].[BI_DimLocal]
        (local_key, local_id_origen, nombre_local, localidad, provincia)
    SELECT
        CONVERT(INT, ROW_NUMBER() OVER (ORDER BY l.local_id)),
        l.local_id,
        l.nombre_local,
        loc.nombre_localidad,
        loc.provincia
    FROM [NUTREAM].[Local] AS l
    INNER JOIN [NUTREAM].[Localidad] AS loc ON loc.localidad_id = l.localidad_id;

    INSERT INTO [NUTREAM].[BI_DimTipoProducto]
        (tipo_producto_key, tipo_producto_id_origen, nombre_tipo_producto)
    SELECT
        CONVERT(INT, ROW_NUMBER() OVER (ORDER BY tp.tipo_producto_id)),
        tp.tipo_producto_id,
        tp.tipo_producto
    FROM [NUTREAM].[TipoProducto] AS tp;

    INSERT INTO [NUTREAM].[BI_DimCategoriaBicicleta]
        (categoria_bicicleta_key, categoria_bicicleta_id_origen, nombre_categoria)
    SELECT
        CONVERT(INT, ROW_NUMBER() OVER (ORDER BY cb.categoria_bicicleta_id)),
        cb.categoria_bicicleta_id,
        cb.categoria_bicicleta
    FROM [NUTREAM].[CategoriaBicicleta] AS cb;

    INSERT INTO [NUTREAM].[BI_DimCategoriaRepuesto]
        (categoria_repuesto_key, categoria_repuesto_id_origen, nombre_categoria)
    SELECT
        CONVERT(INT, ROW_NUMBER() OVER (ORDER BY cr.categoria_repuesto_id)),
        cr.categoria_repuesto_id,
        cr.categoria_repuesto
    FROM [NUTREAM].[CategoriaRepuesto] AS cr;

    /*
       Supuesto para los límites que se solapan en la consigna:
       0-25, 26-35, 36-50 y 51 o más años.
    */
    INSERT INTO [NUTREAM].[BI_DimRangoEtario]
        (rango_etario_key, nombre_rango, edad_desde, edad_hasta)
    VALUES
        (1, '0 a 25', 0, 25),
        (2, '26 a 35', 26, 35),
        (3, '36 a 50', 36, 50),
        (4, '51 o más', 51, NULL);

    PRINT '>> [5/26] Cargando dimensiones de rangos etarios y tipos de ingreso...';
    INSERT INTO [NUTREAM].[BI_DimTipoIngresoReparacion]
        (tipo_ingreso_key, nombre_tipo_ingreso)
    VALUES
        (1, 'Mano de obra'),
        (2, 'Repuestos');

    /* Calendario diario desde la primera hasta la última fecha de origen. */
    PRINT '>> [6/26] Generando la dimensión de tiempo...';
    DECLARE @FechaDesde DATE;
    DECLARE @FechaHasta DATE;

    SELECT
        @FechaDesde = MIN(f.fecha),
        @FechaHasta = MAX(f.fecha)
    FROM (
        SELECT CONVERT(DATE, fecha_hora_venta) AS fecha FROM [NUTREAM].[Venta]
        UNION ALL SELECT CONVERT(DATE, fecha_compra) FROM [NUTREAM].[Compra]
        UNION ALL SELECT CONVERT(DATE, fecha_inicio_alquiler) FROM [NUTREAM].[Alquiler]
        UNION ALL SELECT CONVERT(DATE, fecha_ingreso_reparacion) FROM [NUTREAM].[Reparacion]
        UNION ALL SELECT CONVERT(DATE, fecha_entrega_estimada_reparacion) FROM [NUTREAM].[Reparacion]
        UNION ALL SELECT CONVERT(DATE, fecha_entrega_real_reparacion) FROM [NUTREAM].[Reparacion]
        UNION ALL SELECT CONVERT(DATE, fecha_devolucion_real_alquiler) FROM [NUTREAM].[Alquiler]
    ) AS f;

    IF @FechaDesde IS NULL OR @FechaHasta IS NULL
        THROW 51002, 'No se encontraron fechas transaccionales para poblar BI_DimTiempo.', 1;

    ;WITH Calendario AS (
        SELECT @FechaDesde AS fecha
        UNION ALL
        SELECT DATEADD(DAY, 1, fecha)
        FROM Calendario
        WHERE fecha < @FechaHasta
    )
    INSERT INTO [NUTREAM].[BI_DimTiempo]
        (fecha_key, fecha, anio, trimestre, mes, nombre_mes)
    SELECT
        CONVERT(INT, CONVERT(CHAR(8), fecha, 112)),
        fecha,
        YEAR(fecha),
        DATEPART(QUARTER, fecha),
        MONTH(fecha),
        CASE MONTH(fecha)
            WHEN 1 THEN 'Enero' WHEN 2 THEN 'Febrero' WHEN 3 THEN 'Marzo'
            WHEN 4 THEN 'Abril' WHEN 5 THEN 'Mayo' WHEN 6 THEN 'Junio'
            WHEN 7 THEN 'Julio' WHEN 8 THEN 'Agosto' WHEN 9 THEN 'Septiembre'
            WHEN 10 THEN 'Octubre' WHEN 11 THEN 'Noviembre' WHEN 12 THEN 'Diciembre'
        END
    FROM Calendario
    OPTION (MAXRECURSION 0);

    /* Hecho: una fila por venta. */
    PRINT '>> [7/26] Cargando facturación de ventas...';
    INSERT INTO [NUTREAM].[BI_FactVenta]
        (nro_venta, fecha_venta_key, local_key, importe_total_venta, cantidad_ventas)
    SELECT
        v.nro_venta,
        CONVERT(INT, CONVERT(CHAR(8), CONVERT(DATE, v.fecha_hora_venta), 112)),
        dl.local_key,
        v.total_venta,
        1
    FROM [NUTREAM].[Venta] AS v
    INNER JOIN [NUTREAM].[BI_DimLocal] AS dl ON dl.local_id_origen = v.local_id;

    /* Hecho: una fila por venta y tipo. El importe es el subtotal de ese tipo. */
    PRINT '>> [8/26] Cargando ventas agregadas por tipo de producto...';
    ;WITH VentaPorTipo AS (
        SELECT
            v.nro_venta,
            dtp.tipo_producto_key,
            CONVERT(INT, CONVERT(CHAR(8), CONVERT(DATE, v.fecha_hora_venta), 112)) AS fecha_venta_key,
            dl.local_key,
            CASE
                WHEN edad.edad_cliente <= 25 THEN 1
                WHEN edad.edad_cliente <= 35 THEN 2
                WHEN edad.edad_cliente <= 50 THEN 3
                ELSE 4
            END AS rango_etario_key,
            SUM(dv.subtotal_prod_venta) AS importe_tipo_producto_en_venta,
            SUM(dv.cantidad_prod_venta) AS unidades_vendidas
        FROM [NUTREAM].[Venta] AS v
        INNER JOIN [NUTREAM].[Cliente] AS c ON c.cliente_id = v.cliente_id
        INNER JOIN [NUTREAM].[DetalleVenta] AS dv ON dv.nro_venta = v.nro_venta
        INNER JOIN [NUTREAM].[Producto] AS p ON p.cod_producto = dv.cod_producto
        INNER JOIN [NUTREAM].[BI_DimTipoProducto] AS dtp
            ON dtp.tipo_producto_id_origen = p.tipo_producto_id
        INNER JOIN [NUTREAM].[BI_DimLocal] AS dl ON dl.local_id_origen = v.local_id
        CROSS APPLY (
            SELECT DATEDIFF(YEAR, CONVERT(DATE, c.fecha_nacimiento_cliente), CONVERT(DATE, v.fecha_hora_venta))
                - CASE
                    WHEN DATEADD(YEAR,
                        DATEDIFF(YEAR, CONVERT(DATE, c.fecha_nacimiento_cliente), CONVERT(DATE, v.fecha_hora_venta)),
                        CONVERT(DATE, c.fecha_nacimiento_cliente)) > CONVERT(DATE, v.fecha_hora_venta)
                    THEN 1 ELSE 0
                  END AS edad_cliente
        ) AS edad
        GROUP BY
            v.nro_venta,
            dtp.tipo_producto_key,
            CONVERT(INT, CONVERT(CHAR(8), CONVERT(DATE, v.fecha_hora_venta), 112)),
            dl.local_key,
            CASE
                WHEN edad.edad_cliente <= 25 THEN 1
                WHEN edad.edad_cliente <= 35 THEN 2
                WHEN edad.edad_cliente <= 50 THEN 3
                ELSE 4
            END
    )
    INSERT INTO [NUTREAM].[BI_FactVentaTipoProducto]
        (nro_venta, tipo_producto_key, fecha_venta_key, local_key, rango_etario_key,
         importe_tipo_producto_en_venta, unidades_vendidas)
    SELECT
        nro_venta, tipo_producto_key, fecha_venta_key, local_key, rango_etario_key,
        importe_tipo_producto_en_venta, unidades_vendidas
    FROM VentaPorTipo;

    PRINT '>> [9/26] Cargando alquileres y calculando sus horas reales...';
    /*
       Hecho: una fila por alquiler. El mes se asigna por fecha de inicio;
       duración = horas entre inicio y devolución real. Si falta la devolución
       o es anterior al inicio, las horas quedan NULL (no se imputa una estimación).
    */
    INSERT INTO [NUTREAM].[BI_FactAlquiler]
        (nro_alquiler, fecha_inicio_key, local_key, categoria_bicicleta_key,
         horas_alquiler, importe_total_alquiler, cantidad_alquileres)
    SELECT
        a.nro_alquiler,
        CONVERT(INT, CONVERT(CHAR(8), CONVERT(DATE, a.fecha_inicio_alquiler), 112)),
        dl.local_key,
        dcb.categoria_bicicleta_key,
        CASE
            WHEN a.fecha_devolucion_real_alquiler IS NOT NULL
             AND a.fecha_devolucion_real_alquiler >= a.fecha_inicio_alquiler
            THEN CONVERT(NUMERIC(10,2), ROUND(
                DATEDIFF_BIG(SECOND, a.fecha_inicio_alquiler, a.fecha_devolucion_real_alquiler) / 3600.0, 2))
            ELSE NULL
        END,
        a.importe_total_alquiler,
        1
    FROM [NUTREAM].[Alquiler] AS a
    INNER JOIN [NUTREAM].[BicicletaAlquiler] AS ba
        ON ba.nro_serie_bici_alquiler = a.nro_serie_bici_alquiler
    INNER JOIN [NUTREAM].[ModeloBicicleta] AS mb ON mb.modelo_bicicleta_id = ba.modelo_bicicleta_id
    INNER JOIN [NUTREAM].[BI_DimCategoriaBicicleta] AS dcb
        ON dcb.categoria_bicicleta_id_origen = mb.categoria_bicicleta_id
    INNER JOIN [NUTREAM].[BI_DimLocal] AS dl ON dl.local_id_origen = ba.local_id;

    PRINT '>> [10/26] Cargando desvíos de entrega de reparaciones...';
    /*
       Hecho: reparaciones entregadas; el período se determina por la fecha real
       de entrega y el desvío se calcula en días calendario. Reparaciones aún no
       entregadas no se incluyen en este indicador.
    */
    INSERT INTO [NUTREAM].[BI_FactReparacion]
        (nro_reparacion, fecha_entrega_real_key, local_key, desvio_entrega_dias)
    SELECT
        r.nro_reparacion,
        CONVERT(INT, CONVERT(CHAR(8), CONVERT(DATE, r.fecha_entrega_real_reparacion), 112)),
        dl.local_key,
        DATEDIFF(DAY, CONVERT(DATE, r.fecha_entrega_estimada_reparacion),
                      CONVERT(DATE, r.fecha_entrega_real_reparacion))
    FROM [NUTREAM].[Reparacion] AS r
    INNER JOIN [NUTREAM].[BI_DimLocal] AS dl ON dl.local_id_origen = r.local_id
    WHERE r.fecha_entrega_real_reparacion IS NOT NULL;

    PRINT '>> [11/26] Cargando repuestos utilizados en reparaciones...';
    /* Hecho: una fila por renglón de repuesto, imputado al mes de ingreso de la reparación. */
    INSERT INTO [NUTREAM].[BI_FactRepuestoUsado]
        (detalle_reparacion_id, fecha_reparacion_key, local_key,
         categoria_repuesto_key, unidades_utilizadas)
    SELECT
        dr.detalle_reparacion_id,
        CONVERT(INT, CONVERT(CHAR(8), CONVERT(DATE, r.fecha_ingreso_reparacion), 112)),
        dl.local_key,
        dcr.categoria_repuesto_key,
        dr.cantidad_repuesto
    FROM [NUTREAM].[DetalleReparacion] AS dr
    INNER JOIN [NUTREAM].[Reparacion] AS r ON r.nro_reparacion = dr.nro_reparacion
    INNER JOIN [NUTREAM].[Repuesto] AS rep ON rep.cod_repuesto = dr.cod_repuesto
    INNER JOIN [NUTREAM].[BI_DimCategoriaRepuesto] AS dcr
        ON dcr.categoria_repuesto_id_origen = rep.categoria_repuesto_id
    INNER JOIN [NUTREAM].[BI_DimLocal] AS dl ON dl.local_id_origen = r.local_id;

    PRINT '>> [12/26] Cargando facturación de reparaciones por tipo de ingreso...';
    /*
       Hecho: dos filas por reparación completada, mano de obra y repuestos.
       La facturación se imputa al mes de entrega real; reparaciones sin fecha
       real no se incluyen porque todavía no se consideran entregadas/facturadas.
    */
    INSERT INTO [NUTREAM].[BI_FactIngresoReparacion]
        (nro_reparacion, tipo_ingreso_key, fecha_entrega_real_key, local_key, importe_ingreso)
    SELECT
        r.nro_reparacion,
        ti.tipo_ingreso_key,
        CONVERT(INT, CONVERT(CHAR(8), CONVERT(DATE, r.fecha_entrega_real_reparacion), 112)),
        dl.local_key,
        CASE ti.tipo_ingreso_key
            WHEN 1 THEN r.precio_mano_obra_reparacion
            WHEN 2 THEN r.precio_repuestos_reparacion
        END
    FROM [NUTREAM].[Reparacion] AS r
    CROSS JOIN [NUTREAM].[BI_DimTipoIngresoReparacion] AS ti
    INNER JOIN [NUTREAM].[BI_DimLocal] AS dl ON dl.local_id_origen = r.local_id
    WHERE r.fecha_entrega_real_reparacion IS NOT NULL;

    PRINT '>> [13/26] Cargando importes de compras...';
    /* Hecho: una fila por compra. */
    INSERT INTO [NUTREAM].[BI_FactCompra]
        (nro_compra, fecha_compra_key, local_key, importe_total_compra, cantidad_compras)
    SELECT
        c.nro_compra,
        CONVERT(INT, CONVERT(CHAR(8), CONVERT(DATE, c.fecha_compra), 112)),
        dl.local_key,
        c.total_compra,
        1
    FROM [NUTREAM].[Compra] AS c
    INNER JOIN [NUTREAM].[BI_DimLocal] AS dl ON dl.local_id_origen = c.local_id;

    PRINT '>> [14/26] Cargando unidades compradas por tipo de producto...';
    /* Hecho: una fila por compra y tipo, con unidades agregadas por tipo. */
    INSERT INTO [NUTREAM].[BI_FactCompraTipoProducto]
        (nro_compra, tipo_producto_key, fecha_compra_key, local_key, unidades_compradas)
    SELECT
        c.nro_compra,
        dtp.tipo_producto_key,
        CONVERT(INT, CONVERT(CHAR(8), CONVERT(DATE, c.fecha_compra), 112)),
        dl.local_key,
        SUM(dc.cantidad_prod_compra)
    FROM [NUTREAM].[Compra] AS c
    INNER JOIN [NUTREAM].[DetalleCompra] AS dc ON dc.nro_compra = c.nro_compra
    INNER JOIN [NUTREAM].[Producto] AS p ON p.cod_producto = dc.cod_producto
    INNER JOIN [NUTREAM].[BI_DimTipoProducto] AS dtp
        ON dtp.tipo_producto_id_origen = p.tipo_producto_id
    INNER JOIN [NUTREAM].[BI_DimLocal] AS dl ON dl.local_id_origen = c.local_id
    GROUP BY
        c.nro_compra,
        dtp.tipo_producto_key,
        CONVERT(INT, CONVERT(CHAR(8), CONVERT(DATE, c.fecha_compra), 112)),
        dl.local_key;

    /* Vistas requeridas: una vista por indicador del enunciado. */
    PRINT '>> [15/26] Creando vista del indicador 1: facturación mensual de ventas...';
    EXEC(N'
    CREATE VIEW [NUTREAM].[BI_VistaIndicador01_FacturacionVentasMensual]
    AS
    SELECT t.anio, t.mes, l.local_key, l.nombre_local,
           SUM(f.importe_total_venta) AS facturacion_ventas
    FROM [NUTREAM].[BI_FactVenta] AS f
    INNER JOIN [NUTREAM].[BI_DimTiempo] AS t ON t.fecha_key = f.fecha_venta_key
    INNER JOIN [NUTREAM].[BI_DimLocal] AS l ON l.local_key = f.local_key
    GROUP BY t.anio, t.mes, l.local_key, l.nombre_local;
    ');

    PRINT '>> [16/26] Creando vista del indicador 2: ticket promedio por tipo y edad...';
    EXEC(N'
    CREATE VIEW [NUTREAM].[BI_VistaIndicador02_TicketPromedioPorTipoYEdad]
    AS
    SELECT t.anio, t.mes, tp.tipo_producto_key, tp.nombre_tipo_producto,
           re.rango_etario_key, re.nombre_rango,
           AVG(CONVERT(DECIMAL(38,2), f.importe_tipo_producto_en_venta)) AS ticket_promedio_tipo
    FROM [NUTREAM].[BI_FactVentaTipoProducto] AS f
    INNER JOIN [NUTREAM].[BI_DimTiempo] AS t ON t.fecha_key = f.fecha_venta_key
    INNER JOIN [NUTREAM].[BI_DimTipoProducto] AS tp ON tp.tipo_producto_key = f.tipo_producto_key
    INNER JOIN [NUTREAM].[BI_DimRangoEtario] AS re ON re.rango_etario_key = f.rango_etario_key
    GROUP BY t.anio, t.mes, tp.tipo_producto_key, tp.nombre_tipo_producto,
             re.rango_etario_key, re.nombre_rango;
    ');

    PRINT '>> [17/26] Creando vista del indicador 3: porcentaje de ventas por tipo y local...';
    EXEC(N'
    CREATE VIEW [NUTREAM].[BI_VistaIndicador03_PorcentajeVentasPorTipoYLocal]
    AS
    WITH VentasPorTipo AS (
        SELECT t.anio, t.trimestre, l.local_key, l.nombre_local,
               tp.tipo_producto_key, tp.nombre_tipo_producto,
               SUM(f.importe_tipo_producto_en_venta) AS importe_tipo
        FROM [NUTREAM].[BI_FactVentaTipoProducto] AS f
        INNER JOIN [NUTREAM].[BI_DimTiempo] AS t ON t.fecha_key = f.fecha_venta_key
        INNER JOIN [NUTREAM].[BI_DimLocal] AS l ON l.local_key = f.local_key
        INNER JOIN [NUTREAM].[BI_DimTipoProducto] AS tp ON tp.tipo_producto_key = f.tipo_producto_key
        GROUP BY t.anio, t.trimestre, l.local_key, l.nombre_local,
                 tp.tipo_producto_key, tp.nombre_tipo_producto
    )
    SELECT anio, trimestre, local_key, nombre_local, tipo_producto_key, nombre_tipo_producto,
           importe_tipo,
           CONVERT(DECIMAL(9,4), 100.0 * importe_tipo /
               NULLIF(SUM(importe_tipo) OVER (PARTITION BY anio, trimestre, local_key), 0)) AS porcentaje_ventas
    FROM VentasPorTipo;
    ');

    PRINT '>> [18/26] Creando vista del indicador 4: promedio de horas de alquiler...';
    EXEC(N'
    CREATE VIEW [NUTREAM].[BI_VistaIndicador04_PromedioHorasAlquiler]
    AS
    SELECT t.anio, t.mes, l.local_key, l.nombre_local,
           AVG(f.horas_alquiler) AS promedio_horas_alquiler
    FROM [NUTREAM].[BI_FactAlquiler] AS f
    INNER JOIN [NUTREAM].[BI_DimTiempo] AS t ON t.fecha_key = f.fecha_inicio_key
    INNER JOIN [NUTREAM].[BI_DimLocal] AS l ON l.local_key = f.local_key
    GROUP BY t.anio, t.mes, l.local_key, l.nombre_local;
    ');

    PRINT '>> [19/26] Creando vista del indicador 5: cinco categorías más alquiladas...';
    EXEC(N'
    CREATE VIEW [NUTREAM].[BI_VistaIndicador05_CincoCategoriasMasAlquiladas]
    AS
    WITH AlquileresPorCategoria AS (
        SELECT t.anio, c.categoria_bicicleta_key, c.nombre_categoria,
               SUM(f.cantidad_alquileres) AS cantidad_alquileres
        FROM [NUTREAM].[BI_FactAlquiler] AS f
        INNER JOIN [NUTREAM].[BI_DimTiempo] AS t ON t.fecha_key = f.fecha_inicio_key
        INNER JOIN [NUTREAM].[BI_DimCategoriaBicicleta] AS c
            ON c.categoria_bicicleta_key = f.categoria_bicicleta_key
        GROUP BY t.anio, c.categoria_bicicleta_key, c.nombre_categoria
    ),
    Ranking AS (
        SELECT anio, categoria_bicicleta_key, nombre_categoria, cantidad_alquileres,
               ROW_NUMBER() OVER (PARTITION BY anio ORDER BY cantidad_alquileres DESC, nombre_categoria) AS posicion
        FROM AlquileresPorCategoria
    )
    SELECT anio, posicion, categoria_bicicleta_key, nombre_categoria, cantidad_alquileres
    FROM Ranking
    WHERE posicion <= 5;
    ');

    PRINT '>> [20/26] Creando vista del indicador 6: desvío de entrega de reparaciones...';
    EXEC(N'
    CREATE VIEW [NUTREAM].[BI_VistaIndicador06_DesvioEntregaReparaciones]
    AS
    SELECT t.anio, t.trimestre, l.local_key, l.nombre_local,
           AVG(CONVERT(DECIMAL(10,2), f.desvio_entrega_dias)) AS desvio_promedio_dias
    FROM [NUTREAM].[BI_FactReparacion] AS f
    INNER JOIN [NUTREAM].[BI_DimTiempo] AS t ON t.fecha_key = f.fecha_entrega_real_key
    INNER JOIN [NUTREAM].[BI_DimLocal] AS l ON l.local_key = f.local_key
    GROUP BY t.anio, t.trimestre, l.local_key, l.nombre_local;
    ');

    PRINT '>> [21/26] Creando vista del indicador 7: ranking de repuestos utilizados...';
    EXEC(N'
    CREATE VIEW [NUTREAM].[BI_VistaIndicador07_RankingRepuestosUsados]
    AS
    WITH UsoMensual AS (
        SELECT t.anio, t.mes, c.categoria_repuesto_key, c.nombre_categoria,
               SUM(f.unidades_utilizadas) AS unidades_utilizadas
        FROM [NUTREAM].[BI_FactRepuestoUsado] AS f
        INNER JOIN [NUTREAM].[BI_DimTiempo] AS t ON t.fecha_key = f.fecha_reparacion_key
        INNER JOIN [NUTREAM].[BI_DimCategoriaRepuesto] AS c
            ON c.categoria_repuesto_key = f.categoria_repuesto_key
        GROUP BY t.anio, t.mes, c.categoria_repuesto_key, c.nombre_categoria
    )
    SELECT anio, mes, categoria_repuesto_key, nombre_categoria, unidades_utilizadas,
           DENSE_RANK() OVER (PARTITION BY anio, mes ORDER BY unidades_utilizadas DESC) AS posicion
    FROM UsoMensual;
    ');

    PRINT '>> [22/26] Creando vista del indicador 8: facturación de reparaciones por tipo...';
    EXEC(N'
    CREATE VIEW [NUTREAM].[BI_VistaIndicador08_PorcentajeFacturacionReparaciones]
    AS
    WITH IngresosPorTipo AS (
        SELECT t.anio, t.trimestre, ti.tipo_ingreso_key, ti.nombre_tipo_ingreso,
               SUM(f.importe_ingreso) AS importe_tipo
        FROM [NUTREAM].[BI_FactIngresoReparacion] AS f
        INNER JOIN [NUTREAM].[BI_DimTiempo] AS t ON t.fecha_key = f.fecha_entrega_real_key
        INNER JOIN [NUTREAM].[BI_DimTipoIngresoReparacion] AS ti
            ON ti.tipo_ingreso_key = f.tipo_ingreso_key
        GROUP BY t.anio, t.trimestre, ti.tipo_ingreso_key, ti.nombre_tipo_ingreso
    )
    SELECT anio, trimestre, tipo_ingreso_key, nombre_tipo_ingreso, importe_tipo,
           CONVERT(DECIMAL(9,4), 100.0 * importe_tipo /
               NULLIF(SUM(importe_tipo) OVER (PARTITION BY anio, trimestre), 0)) AS porcentaje_facturacion
    FROM IngresosPorTipo;
    ');

    PRINT '>> [23/26] Creando vista del indicador 9: promedio de unidades compradas...';
    EXEC(N'
    CREATE VIEW [NUTREAM].[BI_VistaIndicador09_PromedioUnidadesCompradas]
    AS
    SELECT t.anio, t.trimestre, tp.tipo_producto_key, tp.nombre_tipo_producto,
           AVG(CONVERT(DECIMAL(38,2), f.unidades_compradas)) AS promedio_unidades_por_compra
    FROM [NUTREAM].[BI_FactCompraTipoProducto] AS f
    INNER JOIN [NUTREAM].[BI_DimTiempo] AS t ON t.fecha_key = f.fecha_compra_key
    INNER JOIN [NUTREAM].[BI_DimTipoProducto] AS tp ON tp.tipo_producto_key = f.tipo_producto_key
    GROUP BY t.anio, t.trimestre, tp.tipo_producto_key, tp.nombre_tipo_producto;
    ');

    PRINT '>> [24/26] Creando vista del indicador 10: compras mensuales por local...';
    EXEC(N'
    CREATE VIEW [NUTREAM].[BI_VistaIndicador10_ComprasMensualesPorLocal]
    AS
    SELECT t.anio, t.mes, l.local_key, l.nombre_local,
           SUM(f.importe_total_compra) AS importe_compras
    FROM [NUTREAM].[BI_FactCompra] AS f
    INNER JOIN [NUTREAM].[BI_DimTiempo] AS t ON t.fecha_key = f.fecha_compra_key
    INNER JOIN [NUTREAM].[BI_DimLocal] AS l ON l.local_key = f.local_key
    GROUP BY t.anio, t.mes, l.local_key, l.nombre_local;
    ');

    PRINT '>> [25/26] Creando vista del indicador 11: facturación mensual total...';
    EXEC(N'
    CREATE VIEW [NUTREAM].[BI_VistaIndicador11_FacturacionMensualTotal]
    AS
    WITH Movimientos AS (
        SELECT fecha_venta_key AS fecha_key, local_key, importe_total_venta AS importe
        FROM [NUTREAM].[BI_FactVenta]
        UNION ALL
        SELECT fecha_inicio_key, local_key, importe_total_alquiler
        FROM [NUTREAM].[BI_FactAlquiler]
        UNION ALL
        SELECT fecha_entrega_real_key, local_key, importe_ingreso
        FROM [NUTREAM].[BI_FactIngresoReparacion]
    )
    SELECT t.anio, t.mes, l.local_key, l.nombre_local,
           SUM(m.importe) AS facturacion_total
    FROM Movimientos AS m
    INNER JOIN [NUTREAM].[BI_DimTiempo] AS t ON t.fecha_key = m.fecha_key
    INNER JOIN [NUTREAM].[BI_DimLocal] AS l ON l.local_key = m.local_key
    GROUP BY t.anio, t.mes, l.local_key, l.nombre_local;
    ');

    COMMIT TRANSACTION;
    PRINT '>> [26/26] MODELO BI CREADO Y CARGADO; VISTAS GENERADAS EXITOSAMENTE [NUTREAM]';
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
    PRINT '>> ERROR DURANTE LA CREACIÓN, CARGA O GENERACIÓN DE VISTAS BI:';
    THROW;
END CATCH;
