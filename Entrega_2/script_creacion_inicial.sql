/* ============================================================================
   TRABAJO PRÁCTICO: Base de Datos / Gestión de Datos - 2° Cuatrimestre 2026
   GRUPO: 38
   NOMBRE DE GRUPO / ESQUEMA: NUTREAM
   ENTREGA: 2 - Modelo Relacional y Migración
   ARCHIVO: script_creacion_inicial.sql
   ============================================================================ */

USE GD2C_2026;
GO

/* ============================================================================
   1. CREACIÓN DEL ESQUEMA DEL GRUPO
   ============================================================================ */
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'NUTREAM')
BEGIN
    EXEC('CREATE SCHEMA [NUTREAM]');
END
GO

/* ============================================================================
   2. LIMPIEZA PREVIA (Idempotencia)
   ============================================================================ */

-- Eliminación de Procedimientos Almacenados
IF OBJECT_ID('[NUTREAM].[migrar_detalle_reparaciones]', 'P') IS NOT NULL DROP PROCEDURE [NUTREAM].[migrar_detalle_reparaciones];
IF OBJECT_ID('[NUTREAM].[migrar_reparaciones]', 'P') IS NOT NULL DROP PROCEDURE [NUTREAM].[migrar_reparaciones];
IF OBJECT_ID('[NUTREAM].[migrar_alquileres]', 'P') IS NOT NULL DROP PROCEDURE [NUTREAM].[migrar_alquileres];
IF OBJECT_ID('[NUTREAM].[migrar_detalle_compras]', 'P') IS NOT NULL DROP PROCEDURE [NUTREAM].[migrar_detalle_compras];
IF OBJECT_ID('[NUTREAM].[migrar_compras]', 'P') IS NOT NULL DROP PROCEDURE [NUTREAM].[migrar_compras];
IF OBJECT_ID('[NUTREAM].[migrar_detalle_ventas]', 'P') IS NOT NULL DROP PROCEDURE [NUTREAM].[migrar_detalle_ventas];
IF OBJECT_ID('[NUTREAM].[migrar_ventas]', 'P') IS NOT NULL DROP PROCEDURE [NUTREAM].[migrar_ventas];
IF OBJECT_ID('[NUTREAM].[migrar_bicicletas_alquiler]', 'P') IS NOT NULL DROP PROCEDURE [NUTREAM].[migrar_bicicletas_alquiler];
IF OBJECT_ID('[NUTREAM].[migrar_accesorios]', 'P') IS NOT NULL DROP PROCEDURE [NUTREAM].[migrar_accesorios];
IF OBJECT_ID('[NUTREAM].[migrar_bicicletas_venta]', 'P') IS NOT NULL DROP PROCEDURE [NUTREAM].[migrar_bicicletas_venta];
IF OBJECT_ID('[NUTREAM].[migrar_productos]', 'P') IS NOT NULL DROP PROCEDURE [NUTREAM].[migrar_productos];
IF OBJECT_ID('[NUTREAM].[migrar_repuestos]', 'P') IS NOT NULL DROP PROCEDURE [NUTREAM].[migrar_repuestos];
IF OBJECT_ID('[NUTREAM].[migrar_modelos_bicicleta]', 'P') IS NOT NULL DROP PROCEDURE [NUTREAM].[migrar_modelos_bicicleta];
IF OBJECT_ID('[NUTREAM].[migrar_proveedores]', 'P') IS NOT NULL DROP PROCEDURE [NUTREAM].[migrar_proveedores];
IF OBJECT_ID('[NUTREAM].[migrar_empleados]', 'P') IS NOT NULL DROP PROCEDURE [NUTREAM].[migrar_empleados];
IF OBJECT_ID('[NUTREAM].[migrar_clientes]', 'P') IS NOT NULL DROP PROCEDURE [NUTREAM].[migrar_clientes];
IF OBJECT_ID('[NUTREAM].[migrar_locales]', 'P') IS NOT NULL DROP PROCEDURE [NUTREAM].[migrar_locales];
IF OBJECT_ID('[NUTREAM].[migrar_catalogos]', 'P') IS NOT NULL DROP PROCEDURE [NUTREAM].[migrar_catalogos];
IF OBJECT_ID('[NUTREAM].[migrar_localidades]', 'P') IS NOT NULL DROP PROCEDURE [NUTREAM].[migrar_localidades];
GO

-- Eliminación de Tablas (en orden inverso a sus dependencias)
IF OBJECT_ID('[NUTREAM].[DetalleReparacion]', 'U') IS NOT NULL DROP TABLE [NUTREAM].[DetalleReparacion];
IF OBJECT_ID('[NUTREAM].[DetalleCompra]', 'U') IS NOT NULL DROP TABLE [NUTREAM].[DetalleCompra];
IF OBJECT_ID('[NUTREAM].[DetalleVenta]', 'U') IS NOT NULL DROP TABLE [NUTREAM].[DetalleVenta];
IF OBJECT_ID('[NUTREAM].[Reparacion]', 'U') IS NOT NULL DROP TABLE [NUTREAM].[Reparacion];
IF OBJECT_ID('[NUTREAM].[Alquiler]', 'U') IS NOT NULL DROP TABLE [NUTREAM].[Alquiler];
IF OBJECT_ID('[NUTREAM].[Compra]', 'U') IS NOT NULL DROP TABLE [NUTREAM].[Compra];
IF OBJECT_ID('[NUTREAM].[Venta]', 'U') IS NOT NULL DROP TABLE [NUTREAM].[Venta];
IF OBJECT_ID('[NUTREAM].[BicicletaAlquiler]', 'U') IS NOT NULL DROP TABLE [NUTREAM].[BicicletaAlquiler];
IF OBJECT_ID('[NUTREAM].[Accesorio]', 'U') IS NOT NULL DROP TABLE [NUTREAM].[Accesorio];
IF OBJECT_ID('[NUTREAM].[BicicletaVenta]', 'U') IS NOT NULL DROP TABLE [NUTREAM].[BicicletaVenta];
IF OBJECT_ID('[NUTREAM].[Producto]', 'U') IS NOT NULL DROP TABLE [NUTREAM].[Producto];
IF OBJECT_ID('[NUTREAM].[Repuesto]', 'U') IS NOT NULL DROP TABLE [NUTREAM].[Repuesto];
IF OBJECT_ID('[NUTREAM].[ModeloBicicleta]', 'U') IS NOT NULL DROP TABLE [NUTREAM].[ModeloBicicleta];
IF OBJECT_ID('[NUTREAM].[Proveedor]', 'U') IS NOT NULL DROP TABLE [NUTREAM].[Proveedor];
IF OBJECT_ID('[NUTREAM].[Empleado]', 'U') IS NOT NULL DROP TABLE [NUTREAM].[Empleado];
IF OBJECT_ID('[NUTREAM].[Cliente]', 'U') IS NOT NULL DROP TABLE [NUTREAM].[Cliente];
IF OBJECT_ID('[NUTREAM].[Local]', 'U') IS NOT NULL DROP TABLE [NUTREAM].[Local];
IF OBJECT_ID('[NUTREAM].[EstadoBicicletaAlquiler]', 'U') IS NOT NULL DROP TABLE [NUTREAM].[EstadoBicicletaAlquiler];
IF OBJECT_ID('[NUTREAM].[EstadoAlquiler]', 'U') IS NOT NULL DROP TABLE [NUTREAM].[EstadoAlquiler];
IF OBJECT_ID('[NUTREAM].[EstadoReparacion]', 'U') IS NOT NULL DROP TABLE [NUTREAM].[EstadoReparacion];
IF OBJECT_ID('[NUTREAM].[CategoriaRepuesto]', 'U') IS NOT NULL DROP TABLE [NUTREAM].[CategoriaRepuesto];
IF OBJECT_ID('[NUTREAM].[CategoriaAccesorio]', 'U') IS NOT NULL DROP TABLE [NUTREAM].[CategoriaAccesorio];
IF OBJECT_ID('[NUTREAM].[CategoriaBicicleta]', 'U') IS NOT NULL DROP TABLE [NUTREAM].[CategoriaBicicleta];
IF OBJECT_ID('[NUTREAM].[Marca]', 'U') IS NOT NULL DROP TABLE [NUTREAM].[Marca];
IF OBJECT_ID('[NUTREAM].[TipoProducto]', 'U') IS NOT NULL DROP TABLE [NUTREAM].[TipoProducto];
IF OBJECT_ID('[NUTREAM].[FormaPago]', 'U') IS NOT NULL DROP TABLE [NUTREAM].[FormaPago];
IF OBJECT_ID('[NUTREAM].[Localidad]', 'U') IS NOT NULL DROP TABLE [NUTREAM].[Localidad];
GO

/* ============================================================================
   3. CREACIÓN DE TABLAS (DDL)
   ============================================================================ */

-- 3.1 Ubicación y Catálogos Independientes
CREATE TABLE [NUTREAM].[Localidad] (
    localidad_id INT IDENTITY(1,1) NOT NULL,
    nombre_localidad VARCHAR(255) NOT NULL,
    provincia VARCHAR(255) NOT NULL,
    CONSTRAINT PK_Localidad PRIMARY KEY (localidad_id),
    CONSTRAINT UQ_Localidad_Provincia UNIQUE (nombre_localidad, provincia)
);

CREATE TABLE [NUTREAM].[FormaPago] (
    forma_pago_id INT IDENTITY(1,1) NOT NULL,
    forma_pago VARCHAR(255) NOT NULL,
    CONSTRAINT PK_FormaPago PRIMARY KEY (forma_pago_id),
    CONSTRAINT UQ_FormaPago UNIQUE (forma_pago)
);

CREATE TABLE [NUTREAM].[TipoProducto] (
    tipo_producto_id INT IDENTITY(1,1) NOT NULL,
    tipo_producto VARCHAR(255) NOT NULL,
    CONSTRAINT PK_TipoProducto PRIMARY KEY (tipo_producto_id),
    CONSTRAINT UQ_TipoProducto UNIQUE (tipo_producto)
);

CREATE TABLE [NUTREAM].[Marca] (
    marca_id INT IDENTITY(1,1) NOT NULL,
    marca VARCHAR(255) NOT NULL,
    CONSTRAINT PK_Marca PRIMARY KEY (marca_id),
    CONSTRAINT UQ_Marca UNIQUE (marca)
);

CREATE TABLE [NUTREAM].[CategoriaBicicleta] (
    categoria_bicicleta_id INT IDENTITY(1,1) NOT NULL,
    categoria_bicicleta VARCHAR(255) NOT NULL,
    CONSTRAINT PK_CategoriaBicicleta PRIMARY KEY (categoria_bicicleta_id),
    CONSTRAINT UQ_CategoriaBicicleta UNIQUE (categoria_bicicleta)
);

CREATE TABLE [NUTREAM].[CategoriaAccesorio] (
    categoria_accesorio_id INT IDENTITY(1,1) NOT NULL,
    categoria_accesorio VARCHAR(255) NOT NULL,
    CONSTRAINT PK_CategoriaAccesorio PRIMARY KEY (categoria_accesorio_id),
    CONSTRAINT UQ_CategoriaAccesorio UNIQUE (categoria_accesorio)
);

CREATE TABLE [NUTREAM].[CategoriaRepuesto] (
    categoria_repuesto_id INT IDENTITY(1,1) NOT NULL,
    categoria_repuesto VARCHAR(255) NOT NULL,
    CONSTRAINT PK_CategoriaRepuesto PRIMARY KEY (categoria_repuesto_id),
    CONSTRAINT UQ_CategoriaRepuesto UNIQUE (categoria_repuesto)
);

CREATE TABLE [NUTREAM].[EstadoReparacion] (
    estado_reparacion_id INT IDENTITY(1,1) NOT NULL,
    estado_reparacion VARCHAR(255) NOT NULL,
    CONSTRAINT PK_EstadoReparacion PRIMARY KEY (estado_reparacion_id),
    CONSTRAINT UQ_EstadoReparacion UNIQUE (estado_reparacion)
);

CREATE TABLE [NUTREAM].[EstadoAlquiler] (
    estado_alquiler_id INT IDENTITY(1,1) NOT NULL,
    estado_alquiler VARCHAR(255) NOT NULL,
    CONSTRAINT PK_EstadoAlquiler PRIMARY KEY (estado_alquiler_id),
    CONSTRAINT UQ_EstadoAlquiler UNIQUE (estado_alquiler)
);

CREATE TABLE [NUTREAM].[EstadoBicicletaAlquiler] (
    estado_bici_alquiler_id INT IDENTITY(1,1) NOT NULL,
    estado_bici_alquiler VARCHAR(255) NOT NULL,
    CONSTRAINT PK_EstadoBicicletaAlquiler PRIMARY KEY (estado_bici_alquiler_id),
    CONSTRAINT UQ_EstadoBicicletaAlquiler UNIQUE (estado_bici_alquiler)
);
GO

-- 3.2 Entidades de Personas, Locales y Proveedores
CREATE TABLE [NUTREAM].[Local] (
    local_id INT IDENTITY(1,1) NOT NULL,
    nombre_local VARCHAR(255) NOT NULL,
    telefono_local VARCHAR(255) NOT NULL,
    email_local VARCHAR(255) NOT NULL,
    direccion_local VARCHAR(255) NOT NULL,
    localidad_id INT NOT NULL,
    CONSTRAINT PK_Local PRIMARY KEY (local_id),
    CONSTRAINT FK_Local_Localidad FOREIGN KEY (localidad_id) REFERENCES [NUTREAM].[Localidad](localidad_id),
    CONSTRAINT UQ_Local_Nombre UNIQUE (nombre_local)
);

CREATE TABLE [NUTREAM].[Cliente] (
    cliente_id INT IDENTITY(1,1) NOT NULL,
    nombre_cliente VARCHAR(255) NOT NULL,
    apellido_cliente VARCHAR(255) NOT NULL,
    dni_cliente VARCHAR(255) NOT NULL,
    telefono_cliente VARCHAR(255) NOT NULL,
    email_cliente VARCHAR(255) NOT NULL,
    direccion_cliente VARCHAR(255) NOT NULL,
    fecha_nacimiento_cliente DATETIME2 NOT NULL,
    localidad_id INT NOT NULL,
    CONSTRAINT PK_Cliente PRIMARY KEY (cliente_id),
    CONSTRAINT FK_Cliente_Localidad FOREIGN KEY (localidad_id) REFERENCES [NUTREAM].[Localidad](localidad_id)
);

CREATE TABLE [NUTREAM].[Empleado] (
    empleado_id INT IDENTITY(1,1) NOT NULL,
    nombre_empleado VARCHAR(255) NOT NULL,
    apellido_empleado VARCHAR(255) NOT NULL,
    dni_empleado VARCHAR(255) NOT NULL,
    puesto_empleado VARCHAR(255) NOT NULL,
    fecha_ingreso_empleado DATETIME2 NOT NULL,
    telefono_empleado VARCHAR(255) NOT NULL,
    email_empleado VARCHAR(255) NOT NULL,
    domicilio_empleado VARCHAR(255) NOT NULL,
    fecha_nac_empleado DATETIME2 NOT NULL,
    localidad_id INT NOT NULL,
    CONSTRAINT PK_Empleado PRIMARY KEY (empleado_id),
    CONSTRAINT FK_Empleado_Localidad FOREIGN KEY (localidad_id) REFERENCES [NUTREAM].[Localidad](localidad_id),
    CONSTRAINT UQ_Empleado_DNI UNIQUE (dni_empleado)
);

CREATE TABLE [NUTREAM].[Proveedor] (
    proveedor_id INT IDENTITY(1,1) NOT NULL,
    razon_social_proveedor VARCHAR(255) NOT NULL,
    cuit_proveedor VARCHAR(255) NOT NULL,
    telefono_proveedor VARCHAR(255) NOT NULL,
    email_proveedor VARCHAR(255) NOT NULL,
    direccion_proveedor VARCHAR(255) NOT NULL,
    localidad_id INT NOT NULL,
    CONSTRAINT PK_Proveedor PRIMARY KEY (proveedor_id),
    CONSTRAINT FK_Proveedor_Localidad FOREIGN KEY (localidad_id) REFERENCES [NUTREAM].[Localidad](localidad_id),
    CONSTRAINT UQ_Proveedor_CUIT UNIQUE (cuit_proveedor)
);
GO

-- 3.3 Modelos, Repuestos, Productos y Flota
CREATE TABLE [NUTREAM].[ModeloBicicleta] (
    modelo_bicicleta_id INT IDENTITY(1,1) NOT NULL,
    modelo_bicicleta VARCHAR(255) NOT NULL,
    rodado_modelo_bicicleta VARCHAR(255) NOT NULL,
    cuadro_modelo_bicicleta VARCHAR(255) NOT NULL,
    color_modelo_bicicleta VARCHAR(255) NOT NULL,
    marca_id INT NOT NULL,
    categoria_bicicleta_id INT NOT NULL,
    CONSTRAINT PK_ModeloBicicleta PRIMARY KEY (modelo_bicicleta_id),
    CONSTRAINT FK_ModeloBicicleta_Marca FOREIGN KEY (marca_id) REFERENCES [NUTREAM].[Marca](marca_id),
    CONSTRAINT FK_ModeloBicicleta_Categoria FOREIGN KEY (categoria_bicicleta_id) REFERENCES [NUTREAM].[CategoriaBicicleta](categoria_bicicleta_id),
    CONSTRAINT UQ_ModeloBicicleta_Nombre UNIQUE (modelo_bicicleta)
);

CREATE TABLE [NUTREAM].[Repuesto] (
    cod_repuesto VARCHAR(255) NOT NULL,
    desc_repuesto VARCHAR(255) NOT NULL,
    compatibilidad_repuesto VARCHAR(255) NOT NULL,
    precio_repuesto NUMERIC(38,2) NOT NULL,
    categoria_repuesto_id INT NOT NULL,
    CONSTRAINT PK_Repuesto PRIMARY KEY (cod_repuesto),
    CONSTRAINT FK_Repuesto_Categoria FOREIGN KEY (categoria_repuesto_id) REFERENCES [NUTREAM].[CategoriaRepuesto](categoria_repuesto_id)
);

CREATE TABLE [NUTREAM].[Producto] (
    cod_producto VARCHAR(255) NOT NULL,
    nombre_producto VARCHAR(255) NOT NULL,
    descripcion_producto VARCHAR(255) NOT NULL,
    precio_venta_producto NUMERIC(38,2) NOT NULL,
    tipo_producto_id INT NOT NULL,
    CONSTRAINT PK_Producto PRIMARY KEY (cod_producto),
    CONSTRAINT FK_Producto_TipoProducto FOREIGN KEY (tipo_producto_id) REFERENCES [NUTREAM].[TipoProducto](tipo_producto_id)
);

CREATE TABLE [NUTREAM].[BicicletaVenta] (
    cod_producto VARCHAR(255) NOT NULL,
    modelo_bicicleta_id INT NOT NULL,
    meses_garantia_bici_venta INT NOT NULL,
    CONSTRAINT PK_BicicletaVenta PRIMARY KEY (cod_producto),
    CONSTRAINT FK_BicicletaVenta_Producto FOREIGN KEY (cod_producto) REFERENCES [NUTREAM].[Producto](cod_producto),
    CONSTRAINT FK_BicicletaVenta_Modelo FOREIGN KEY (modelo_bicicleta_id) REFERENCES [NUTREAM].[ModeloBicicleta](modelo_bicicleta_id)
);

CREATE TABLE [NUTREAM].[Accesorio] (
    cod_producto VARCHAR(255) NOT NULL,
    talle_accesorio VARCHAR(255) NOT NULL,
    color_accesorio VARCHAR(255) NOT NULL,
    marca_id INT NOT NULL,
    categoria_accesorio_id INT NOT NULL,
    CONSTRAINT PK_Accesorio PRIMARY KEY (cod_producto),
    CONSTRAINT FK_Accesorio_Producto FOREIGN KEY (cod_producto) REFERENCES [NUTREAM].[Producto](cod_producto),
    CONSTRAINT FK_Accesorio_Marca FOREIGN KEY (marca_id) REFERENCES [NUTREAM].[Marca](marca_id),
    CONSTRAINT FK_Accesorio_Categoria FOREIGN KEY (categoria_accesorio_id) REFERENCES [NUTREAM].[CategoriaAccesorio](categoria_accesorio_id)
);

CREATE TABLE [NUTREAM].[BicicletaAlquiler] (
    nro_serie_bici_alquiler VARCHAR(255) NOT NULL,
    modelo_bicicleta_id INT NOT NULL,
    precio_bici_alquiler_hora NUMERIC(38,2) NOT NULL,
    precio_bici_alquiler_dia NUMERIC(38,2) NOT NULL,
    estado_bici_alquiler_id INT NOT NULL,
    local_id INT NOT NULL,
    CONSTRAINT PK_BicicletaAlquiler PRIMARY KEY (nro_serie_bici_alquiler),
    CONSTRAINT FK_BicicletaAlquiler_Modelo FOREIGN KEY (modelo_bicicleta_id) REFERENCES [NUTREAM].[ModeloBicicleta](modelo_bicicleta_id),
    CONSTRAINT FK_BicicletaAlquiler_Estado FOREIGN KEY (estado_bici_alquiler_id) REFERENCES [NUTREAM].[EstadoBicicletaAlquiler](estado_bici_alquiler_id),
    CONSTRAINT FK_BicicletaAlquiler_Local FOREIGN KEY (local_id) REFERENCES [NUTREAM].[Local](local_id)
);
GO

-- 3.4 Operaciones Transaccionales y Detalles
CREATE TABLE [NUTREAM].[Venta] (
    nro_venta INT NOT NULL,
    fecha_hora_venta DATETIME2 NOT NULL,
    total_venta NUMERIC(38,2) NOT NULL,
    cliente_id INT NOT NULL,
    empleado_id INT NOT NULL,
    forma_pago_id INT NOT NULL,
    local_id INT NOT NULL,
    CONSTRAINT PK_Venta PRIMARY KEY (nro_venta),
    CONSTRAINT FK_Venta_Cliente FOREIGN KEY (cliente_id) REFERENCES [NUTREAM].[Cliente](cliente_id),
    CONSTRAINT FK_Venta_Empleado FOREIGN KEY (empleado_id) REFERENCES [NUTREAM].[Empleado](empleado_id),
    CONSTRAINT FK_Venta_FormaPago FOREIGN KEY (forma_pago_id) REFERENCES [NUTREAM].[FormaPago](forma_pago_id),
    CONSTRAINT FK_Venta_Local FOREIGN KEY (local_id) REFERENCES [NUTREAM].[Local](local_id)
);

CREATE TABLE [NUTREAM].[DetalleVenta] (
    detalle_venta_id INT IDENTITY(1,1) NOT NULL,
    nro_venta INT NOT NULL,
    cod_producto VARCHAR(255) NOT NULL,
    cantidad_prod_venta INT NOT NULL,
    precio_unitario_prod_venta NUMERIC(38,2) NOT NULL,
    subtotal_prod_venta NUMERIC(38,2) NOT NULL,
    CONSTRAINT PK_DetalleVenta PRIMARY KEY (detalle_venta_id),
    CONSTRAINT FK_DetalleVenta_Venta FOREIGN KEY (nro_venta) REFERENCES [NUTREAM].[Venta](nro_venta),
    CONSTRAINT FK_DetalleVenta_Producto FOREIGN KEY (cod_producto) REFERENCES [NUTREAM].[Producto](cod_producto)
);

CREATE TABLE [NUTREAM].[Compra] (
    nro_compra INT NOT NULL,
    local_id INT NOT NULL,
    fecha_compra DATETIME2 NOT NULL,
    total_compra NUMERIC(38,2) NOT NULL,
    proveedor_id INT NOT NULL,
    empleado_id INT NOT NULL,
    CONSTRAINT PK_Compra PRIMARY KEY (nro_compra),
    CONSTRAINT FK_Compra_Local FOREIGN KEY (local_id) REFERENCES [NUTREAM].[Local](local_id),
    CONSTRAINT FK_Compra_Proveedor FOREIGN KEY (proveedor_id) REFERENCES [NUTREAM].[Proveedor](proveedor_id),
    CONSTRAINT FK_Compra_Empleado FOREIGN KEY (empleado_id) REFERENCES [NUTREAM].[Empleado](empleado_id)
);

CREATE TABLE [NUTREAM].[DetalleCompra] (
    detalle_compra_id INT IDENTITY(1,1) NOT NULL,
    nro_compra INT NOT NULL,
    cod_producto VARCHAR(255) NOT NULL,
    cantidad_prod_compra INT NOT NULL,
    precio_unitario_prod_compra NUMERIC(38,2) NOT NULL,
    CONSTRAINT PK_DetalleCompra PRIMARY KEY (detalle_compra_id),
    CONSTRAINT FK_DetalleCompra_Compra FOREIGN KEY (nro_compra) REFERENCES [NUTREAM].[Compra](nro_compra),
    CONSTRAINT FK_DetalleCompra_Producto FOREIGN KEY (cod_producto) REFERENCES [NUTREAM].[Producto](cod_producto)
);

CREATE TABLE [NUTREAM].[Alquiler] (
    nro_alquiler INT NOT NULL,
    fecha_inicio_alquiler DATETIME2 NOT NULL,
    fecha_fin_pactada_alquiler DATETIME2 NOT NULL,
    fecha_devolucion_real_alquiler DATETIME2 NOT NULL,
    importe_total_alquiler NUMERIC(38,2) NOT NULL,
    cliente_id INT NOT NULL,
    empleado_id INT NOT NULL,
    nro_serie_bici_alquiler VARCHAR(255) NOT NULL,
    forma_pago_id INT NOT NULL,
    estado_alquiler_id INT NOT NULL,
    CONSTRAINT PK_Alquiler PRIMARY KEY (nro_alquiler),
    CONSTRAINT FK_Alquiler_Cliente FOREIGN KEY (cliente_id) REFERENCES [NUTREAM].[Cliente](cliente_id),
    CONSTRAINT FK_Alquiler_Empleado FOREIGN KEY (empleado_id) REFERENCES [NUTREAM].[Empleado](empleado_id),
    CONSTRAINT FK_Alquiler_BicicletaAlquiler FOREIGN KEY (nro_serie_bici_alquiler) REFERENCES [NUTREAM].[BicicletaAlquiler](nro_serie_bici_alquiler),
    CONSTRAINT FK_Alquiler_FormaPago FOREIGN KEY (forma_pago_id) REFERENCES [NUTREAM].[FormaPago](forma_pago_id),
    CONSTRAINT FK_Alquiler_Estado FOREIGN KEY (estado_alquiler_id) REFERENCES [NUTREAM].[EstadoAlquiler](estado_alquiler_id)
);

CREATE TABLE [NUTREAM].[Reparacion] (
    nro_reparacion INT NOT NULL,
    numero_serie_bici_reparacion VARCHAR(255) NOT NULL,
    fecha_ingreso_reparacion DATETIME2 NOT NULL,
    fecha_entrega_estimada_reparacion DATETIME2 NOT NULL,
    fecha_entrega_real_reparacion DATETIME2 NOT NULL,
    diagnostico_reparacion VARCHAR(255) NOT NULL,
    precio_mano_obra_reparacion NUMERIC(38,2) NOT NULL,
    precio_repuestos_reparacion NUMERIC(38,2) NOT NULL,
    precio_total_reparacion NUMERIC(38,2) NOT NULL,
    local_id INT NOT NULL,
    cliente_id INT NOT NULL,
    empleado_id INT NOT NULL,
    modelo_bicicleta_id INT NOT NULL,
    estado_reparacion_id INT NOT NULL,
    CONSTRAINT PK_Reparacion PRIMARY KEY (nro_reparacion),
    CONSTRAINT FK_Reparacion_Local FOREIGN KEY (local_id) REFERENCES [NUTREAM].[Local](local_id),
    CONSTRAINT FK_Reparacion_Cliente FOREIGN KEY (cliente_id) REFERENCES [NUTREAM].[Cliente](cliente_id),
    CONSTRAINT FK_Reparacion_Empleado FOREIGN KEY (empleado_id) REFERENCES [NUTREAM].[Empleado](empleado_id),
    CONSTRAINT FK_Reparacion_Modelo FOREIGN KEY (modelo_bicicleta_id) REFERENCES [NUTREAM].[ModeloBicicleta](modelo_bicicleta_id),
    CONSTRAINT FK_Reparacion_Estado FOREIGN KEY (estado_reparacion_id) REFERENCES [NUTREAM].[EstadoReparacion](estado_reparacion_id)
);

CREATE TABLE [NUTREAM].[DetalleReparacion] (
    detalle_reparacion_id INT IDENTITY(1,1) NOT NULL,
    nro_reparacion INT NOT NULL,
    cod_repuesto VARCHAR(255) NOT NULL,
    cantidad_repuesto INT NOT NULL,
    precio_unitario_repuesto NUMERIC(38,2) NOT NULL,
    subtotal_repuesto NUMERIC(38,2) NOT NULL,
    CONSTRAINT PK_DetalleReparacion PRIMARY KEY (detalle_reparacion_id),
    CONSTRAINT FK_DetalleReparacion_Reparacion FOREIGN KEY (nro_reparacion) REFERENCES [NUTREAM].[Reparacion](nro_reparacion),
    CONSTRAINT FK_DetalleReparacion_Repuesto FOREIGN KEY (cod_repuesto) REFERENCES [NUTREAM].[Repuesto](cod_repuesto)
);
GO

/* ============================================================================
   4. STORED PROCEDURES DE MIGRACIÓN
   ============================================================================ */

-- 4.1 Migración de Localidades
CREATE PROCEDURE [NUTREAM].[migrar_localidades]
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO [NUTREAM].[Localidad] (nombre_localidad, provincia)
    SELECT DISTINCT 
        RTRIM(LTRIM(loc.localidad)), 
        RTRIM(LTRIM(loc.provincia))
    FROM (
        SELECT Local_Localidad AS localidad, Local_Provincia AS provincia 
        FROM gd_esquema.Maestra 
        WHERE Local_Localidad IS NOT NULL AND Local_Provincia IS NOT NULL
        UNION
        SELECT Cliente_Localidad, Cliente_Provincia 
        FROM gd_esquema.Maestra 
        WHERE Cliente_Localidad IS NOT NULL AND Cliente_Provincia IS NOT NULL
        UNION
        SELECT Empleado_Localidad, Empleado_Provincia 
        FROM gd_esquema.Maestra 
        WHERE Empleado_Localidad IS NOT NULL AND Empleado_Provincia IS NOT NULL
        UNION
        SELECT Proveedor_Localidad, Proveedor_Provincia 
        FROM gd_esquema.Maestra 
        WHERE Proveedor_Localidad IS NOT NULL AND Proveedor_Provincia IS NOT NULL
    ) AS loc
    ORDER BY RTRIM(LTRIM(loc.provincia)), RTRIM(LTRIM(loc.localidad));
END;
GO

-- 4.2 Migración de Catálogos
CREATE PROCEDURE [NUTREAM].[migrar_catalogos]
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO [NUTREAM].[FormaPago] (forma_pago)
    SELECT DISTINCT RTRIM(LTRIM(Forma_Pago_Forma_Pago))
    FROM gd_esquema.Maestra
    WHERE Forma_Pago_Forma_Pago IS NOT NULL
    ORDER BY 1;

    INSERT INTO [NUTREAM].[TipoProducto] (tipo_producto)
    SELECT DISTINCT RTRIM(LTRIM(Tipo_Producto_Tipo_Producto))
    FROM gd_esquema.Maestra
    WHERE Tipo_Producto_Tipo_Producto IS NOT NULL
    ORDER BY 1;

    INSERT INTO [NUTREAM].[Marca] (marca)
    SELECT DISTINCT RTRIM(LTRIM(Marca_Marca))
    FROM gd_esquema.Maestra
    WHERE Marca_Marca IS NOT NULL
    ORDER BY 1;

    INSERT INTO [NUTREAM].[CategoriaBicicleta] (categoria_bicicleta)
    SELECT DISTINCT RTRIM(LTRIM(Categoria_Bicicleta_Categoria_Bicicleta))
    FROM gd_esquema.Maestra
    WHERE Categoria_Bicicleta_Categoria_Bicicleta IS NOT NULL
    ORDER BY 1;

    INSERT INTO [NUTREAM].[CategoriaAccesorio] (categoria_accesorio)
    SELECT DISTINCT RTRIM(LTRIM(Categoria_Accesorios_Categoria_Accesorio))
    FROM gd_esquema.Maestra
    WHERE Categoria_Accesorios_Categoria_Accesorio IS NOT NULL
    ORDER BY 1;

    INSERT INTO [NUTREAM].[CategoriaRepuesto] (categoria_repuesto)
    SELECT DISTINCT RTRIM(LTRIM(Categoria_Repuestos_Categoria_Respuesto))
    FROM gd_esquema.Maestra
    WHERE Categoria_Repuestos_Categoria_Respuesto IS NOT NULL
    ORDER BY 1;

    INSERT INTO [NUTREAM].[EstadoReparacion] (estado_reparacion)
    SELECT DISTINCT RTRIM(LTRIM(Estado_Reparacion_Estado_Reparacion))
    FROM gd_esquema.Maestra
    WHERE Estado_Reparacion_Estado_Reparacion IS NOT NULL
    ORDER BY 1;

    INSERT INTO [NUTREAM].[EstadoAlquiler] (estado_alquiler)
    SELECT DISTINCT RTRIM(LTRIM(Estado_Alquiler_Estado_Alquiler))
    FROM gd_esquema.Maestra
    WHERE Estado_Alquiler_Estado_Alquiler IS NOT NULL
    ORDER BY 1;

    INSERT INTO [NUTREAM].[EstadoBicicletaAlquiler] (estado_bici_alquiler)
    SELECT DISTINCT RTRIM(LTRIM(Estado_Bici_Alquiler_Estado_Bici_Alquiler))
    FROM gd_esquema.Maestra
    WHERE Estado_Bici_Alquiler_Estado_Bici_Alquiler IS NOT NULL
    ORDER BY 1;
END;
GO

-- 4.3 Migración de Locales
CREATE PROCEDURE [NUTREAM].[migrar_locales]
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO [NUTREAM].[Local] (nombre_local, telefono_local, email_local, direccion_local, localidad_id)
    SELECT DISTINCT 
        RTRIM(LTRIM(m.Local_Nombre_Local)),
        RTRIM(LTRIM(m.Local_Telefono_Local)),
        RTRIM(LTRIM(m.Local_Email_Local)),
        RTRIM(LTRIM(m.Local_Direccion_Local)),
        loc.localidad_id
    FROM gd_esquema.Maestra m
    JOIN [NUTREAM].[Localidad] loc 
        ON loc.nombre_localidad = RTRIM(LTRIM(m.Local_Localidad))
       AND loc.provincia = RTRIM(LTRIM(m.Local_Provincia))
    WHERE m.Local_Nombre_Local IS NOT NULL;
END;
GO

-- 4.4 Migración de Clientes
CREATE PROCEDURE [NUTREAM].[migrar_clientes]
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO [NUTREAM].[Cliente] (
        nombre_cliente, apellido_cliente, dni_cliente, 
        telefono_cliente, email_cliente, direccion_cliente, 
        fecha_nacimiento_cliente, localidad_id
    )
    SELECT DISTINCT 
        RTRIM(LTRIM(m.Cliente_Nombre_Cliente)),
        RTRIM(LTRIM(m.Cliente_Apellido_Cliente)),
        RTRIM(LTRIM(m.Cliente_Dni_Cliente)),
        RTRIM(LTRIM(m.Cliente_Telefono_Cliente)),
        RTRIM(LTRIM(m.Cliente_Email_Cliente)),
        RTRIM(LTRIM(m.Cliente_Direccion_Cliente)),
        m.Cliente_Fecha_Nacimiento_Cliente,
        loc.localidad_id
    FROM gd_esquema.Maestra m
    JOIN [NUTREAM].[Localidad] loc 
        ON loc.nombre_localidad = RTRIM(LTRIM(m.Cliente_Localidad))
       AND loc.provincia = RTRIM(LTRIM(m.Cliente_Provincia))
    WHERE m.Cliente_Dni_Cliente IS NOT NULL;

    -- Índice para optimizar búsquedas masivas durante la migración de operaciones
    CREATE UNIQUE NONCLUSTERED INDEX IX_Cliente_Dni_Email 
    ON [NUTREAM].[Cliente](dni_cliente, email_cliente) 
    INCLUDE (cliente_id);
END;
GO

-- 4.5 Migración de Empleados
CREATE PROCEDURE [NUTREAM].[migrar_empleados]
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO [NUTREAM].[Empleado] (
        nombre_empleado, apellido_empleado, dni_empleado, 
        puesto_empleado, fecha_ingreso_empleado, telefono_empleado, 
        email_empleado, domicilio_empleado, fecha_nac_empleado, localidad_id
    )
    SELECT DISTINCT 
        RTRIM(LTRIM(m.Empleado_Nombre_Empleado)),
        RTRIM(LTRIM(m.Empleado_Apellido_Empleado)),
        RTRIM(LTRIM(m.Empleado_Dni_Empleado)),
        RTRIM(LTRIM(m.Empleado_Puesto_Empleado)),
        m.Empleado_Fecha_Ingreso_Empleado,
        RTRIM(LTRIM(m.Empleado_Telefono_Empleado)),
        RTRIM(LTRIM(m.Empleado_Email_Empleado)),
        RTRIM(LTRIM(m.Empleado_Domicilio_Empleado)),
        m.Empleado_Fecha_Nac_Empleado,
        loc.localidad_id
    FROM gd_esquema.Maestra m
    JOIN [NUTREAM].[Localidad] loc 
        ON loc.nombre_localidad = RTRIM(LTRIM(m.Empleado_Localidad))
       AND loc.provincia = RTRIM(LTRIM(m.Empleado_Provincia))
    WHERE m.Empleado_Dni_Empleado IS NOT NULL;
END;
GO

-- 4.6 Migración de Proveedores
CREATE PROCEDURE [NUTREAM].[migrar_proveedores]
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO [NUTREAM].[Proveedor] (
        razon_social_proveedor, cuit_proveedor, telefono_proveedor, 
        email_proveedor, direccion_proveedor, localidad_id
    )
    SELECT DISTINCT 
        RTRIM(LTRIM(m.Proveedor_Razon_Social_Proveedor)),
        RTRIM(LTRIM(m.Proveedor_Cuit_Proveedor)),
        RTRIM(LTRIM(m.Proveedor_Telefono_Proveedor)),
        RTRIM(LTRIM(m.Proveedor_Email_Proveedor)),
        RTRIM(LTRIM(m.Proveedor_Direccion_Proveedor)),
        loc.localidad_id
    FROM gd_esquema.Maestra m
    JOIN [NUTREAM].[Localidad] loc 
        ON loc.nombre_localidad = RTRIM(LTRIM(m.Proveedor_Localidad))
       AND loc.provincia = RTRIM(LTRIM(m.Proveedor_Provincia))
    WHERE m.Proveedor_Cuit_Proveedor IS NOT NULL;
END;
GO

-- 4.7 Migración de Modelos de Bicicleta
CREATE PROCEDURE [NUTREAM].[migrar_modelos_bicicleta]
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO [NUTREAM].[ModeloBicicleta] (
        modelo_bicicleta, rodado_modelo_bicicleta, 
        cuadro_modelo_bicicleta, color_modelo_bicicleta, 
        marca_id, categoria_bicicleta_id
    )
    SELECT DISTINCT 
        RTRIM(LTRIM(m.Modelo_Bicicleta_Modelo_Bicicleta)),
        RTRIM(LTRIM(m.Modelo_Bicicleta_Rodado_Modelo_Bicicleta)),
        RTRIM(LTRIM(m.Modelo_Bicicleta_Cuadro_Modelo_Bicicleta)),
        RTRIM(LTRIM(m.Modelo_Bicicleta_Color_Modelo_Bicicleta)),
        mar.marca_id,
        cat.categoria_bicicleta_id
    FROM gd_esquema.Maestra m
    JOIN [NUTREAM].[Marca] mar 
        ON mar.marca = RTRIM(LTRIM(m.Marca_Marca))
    JOIN [NUTREAM].[CategoriaBicicleta] cat 
        ON cat.categoria_bicicleta = RTRIM(LTRIM(m.Categoria_Bicicleta_Categoria_Bicicleta))
    WHERE m.Modelo_Bicicleta_Modelo_Bicicleta IS NOT NULL;
END;
GO

-- 4.8 Migración de Repuestos
CREATE PROCEDURE [NUTREAM].[migrar_repuestos]
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO [NUTREAM].[Repuesto] (
        cod_repuesto, desc_repuesto, compatibilidad_repuesto, 
        precio_repuesto, categoria_repuesto_id
    )
    SELECT DISTINCT 
        RTRIM(LTRIM(m.Repuesto_Cod_Repuesto)),
        RTRIM(LTRIM(m.Repuesto_Desc_Repuesto)),
        RTRIM(LTRIM(m.Repuesto_Compatibilidad_Repuesto)),
        m.Repuesto_Precio_Repuesto,
        cat.categoria_repuesto_id
    FROM gd_esquema.Maestra m
    JOIN [NUTREAM].[CategoriaRepuesto] cat 
        ON cat.categoria_repuesto = RTRIM(LTRIM(m.Categoria_Repuestos_Categoria_Respuesto))
    WHERE m.Repuesto_Cod_Repuesto IS NOT NULL;
END;
GO

-- 4.9 Migración de Productos (Supertipo)
CREATE PROCEDURE [NUTREAM].[migrar_productos]
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO [NUTREAM].[Producto] (
        cod_producto, nombre_producto, descripcion_producto, 
        precio_venta_producto, tipo_producto_id
    )
    SELECT DISTINCT 
        RTRIM(LTRIM(m.Producto_Cod_Producto)),
        RTRIM(LTRIM(m.Producto_Nombre_Producto)),
        RTRIM(LTRIM(m.Producto_Descripcion_Producto)),
        m.Producto_Precio_Venta_Producto,
        tp.tipo_producto_id
    FROM gd_esquema.Maestra m
    JOIN [NUTREAM].[TipoProducto] tp 
        ON tp.tipo_producto = RTRIM(LTRIM(m.Tipo_Producto_Tipo_Producto))
    WHERE m.Producto_Cod_Producto IS NOT NULL;
END;
GO

-- 4.10 Migración de Bicicletas para la Venta (Subtipo)
CREATE PROCEDURE [NUTREAM].[migrar_bicicletas_venta]
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO [NUTREAM].[BicicletaVenta] (cod_producto, modelo_bicicleta_id, meses_garantia_bici_venta)
    SELECT DISTINCT 
        RTRIM(LTRIM(m.Producto_Cod_Producto)),
        modBici.modelo_bicicleta_id,
        m.Bicicleta_Venta_Meses_Garantia_Bici_Venta
    FROM gd_esquema.Maestra m
    JOIN [NUTREAM].[ModeloBicicleta] modBici 
        ON modBici.modelo_bicicleta = RTRIM(LTRIM(m.Modelo_Bicicleta_Modelo_Bicicleta))
    WHERE m.Tipo_Producto_Tipo_Producto = 'Bicicleta' 
      AND m.Producto_Cod_Producto IS NOT NULL;
END;
GO

-- 4.11 Migración de Accesorios (Subtipo)
CREATE PROCEDURE [NUTREAM].[migrar_accesorios]
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO [NUTREAM].[Accesorio] (
        cod_producto, talle_accesorio, color_accesorio, 
        marca_id, categoria_accesorio_id
    )
    SELECT DISTINCT 
        RTRIM(LTRIM(m.Producto_Cod_Producto)),
        RTRIM(LTRIM(m.Accesorio_Talle_Accesorio)),
        RTRIM(LTRIM(m.Accesorio_Color_Accesorio)),
        mar.marca_id,
        cat.categoria_accesorio_id
    FROM gd_esquema.Maestra m
    JOIN [NUTREAM].[Marca] mar 
        ON mar.marca = RTRIM(LTRIM(m.Marca_Marca))
    JOIN [NUTREAM].[CategoriaAccesorio] cat 
        ON cat.categoria_accesorio = RTRIM(LTRIM(m.Categoria_Accesorios_Categoria_Accesorio))
    WHERE m.Tipo_Producto_Tipo_Producto = 'Accesorio' 
      AND m.Producto_Cod_Producto IS NOT NULL;
END;
GO

-- 4.12 Migración de Bicicletas de Alquiler (Flota)
CREATE PROCEDURE [NUTREAM].[migrar_bicicletas_alquiler]
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO [NUTREAM].[BicicletaAlquiler] (
        nro_serie_bici_alquiler, modelo_bicicleta_id, 
        precio_bici_alquiler_hora, precio_bici_alquiler_dia, 
        estado_bici_alquiler_id, local_id
    )
    SELECT DISTINCT 
        RTRIM(LTRIM(m.Bicicleta_Alquiler_Nro_Serie_Bici_Alquiler)),
        modBici.modelo_bicicleta_id,
        m.Bicicleta_Alquiler_Precio_Bici_Alquiler_Hora,
        m.Bicicleta_Alquiler_Precio_Bici_Alquiler_Dia,
        est.estado_bici_alquiler_id,
        loc.local_id
    FROM gd_esquema.Maestra m
    JOIN [NUTREAM].[ModeloBicicleta] modBici 
        ON modBici.modelo_bicicleta = RTRIM(LTRIM(m.Modelo_Bicicleta_Modelo_Bicicleta))
    JOIN [NUTREAM].[EstadoBicicletaAlquiler] est 
        ON est.estado_bici_alquiler = RTRIM(LTRIM(m.Estado_Bici_Alquiler_Estado_Bici_Alquiler))
    JOIN [NUTREAM].[Local] loc 
        ON loc.nombre_local = RTRIM(LTRIM(m.Local_Nombre_Local))
    WHERE m.Bicicleta_Alquiler_Nro_Serie_Bici_Alquiler IS NOT NULL;
END;
GO

-- 4.13 Migración de Ventas (Cabecera)
CREATE PROCEDURE [NUTREAM].[migrar_ventas]
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO [NUTREAM].[Venta] (
        nro_venta, fecha_hora_venta, total_venta, 
        cliente_id, empleado_id, forma_pago_id, local_id
    )
    SELECT DISTINCT 
        m.Venta_Nro_Venta,
        m.Venta_Fecha_Hora_Venta,
        m.Venta_Total_Venta,
        c.cliente_id,
        e.empleado_id,
        fp.forma_pago_id,
        loc.local_id
    FROM gd_esquema.Maestra m
    JOIN [NUTREAM].[Cliente] c 
        ON c.dni_cliente = RTRIM(LTRIM(m.Cliente_Dni_Cliente))
       AND c.email_cliente = RTRIM(LTRIM(m.Cliente_Email_Cliente))
    JOIN [NUTREAM].[Empleado] e 
        ON e.dni_empleado = RTRIM(LTRIM(m.Empleado_Dni_Empleado))
    JOIN [NUTREAM].[FormaPago] fp 
        ON fp.forma_pago = RTRIM(LTRIM(m.Forma_Pago_Forma_Pago))
    JOIN [NUTREAM].[Local] loc 
        ON loc.nombre_local = RTRIM(LTRIM(m.Local_Nombre_Local))
    WHERE m.Venta_Nro_Venta IS NOT NULL;
END;
GO

-- 4.14 Migración de Detalle de Ventas
CREATE PROCEDURE [NUTREAM].[migrar_detalle_ventas]
AS
BEGIN
    SET NOCOUNT ON;

    -- Se migra cada renglón de venta registrado en la tabla maestra
    INSERT INTO [NUTREAM].[DetalleVenta] (
        nro_venta, cod_producto, cantidad_prod_venta, 
        precio_unitario_prod_venta, subtotal_prod_venta
    )
    SELECT 
        m.Venta_Nro_Venta,
        RTRIM(LTRIM(m.Producto_Cod_Producto)),
        m.Detalle_Venta_Cantidad_Prod_Venta,
        m.Detalle_Venta_Precio_Unitario_Prod_Venta,
        m.Detalle_Venta_Subtotal_Prod_Venta
    FROM gd_esquema.Maestra m
    WHERE m.Venta_Nro_Venta IS NOT NULL 
      AND m.Producto_Cod_Producto IS NOT NULL;
END;
GO

-- 4.15 Migración de Compras (Cabecera)
CREATE PROCEDURE [NUTREAM].[migrar_compras]
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO [NUTREAM].[Compra] (
        nro_compra, local_id, fecha_compra, total_compra, 
        proveedor_id, empleado_id
    )
    SELECT DISTINCT 
        m.Compra_Nro_Compra,
        loc.local_id,
        m.Compra_Fecha_Compra,
        m.Compra_Total_Compra,
        p.proveedor_id,
        e.empleado_id
    FROM gd_esquema.Maestra m
    JOIN [NUTREAM].[Local] loc 
        ON loc.nombre_local = RTRIM(LTRIM(m.Local_Nombre_Local))
    JOIN [NUTREAM].[Proveedor] p 
        ON p.cuit_proveedor = RTRIM(LTRIM(m.Proveedor_Cuit_Proveedor))
    JOIN [NUTREAM].[Empleado] e 
        ON e.dni_empleado = RTRIM(LTRIM(m.Empleado_Dni_Empleado))
    WHERE m.Compra_Nro_Compra IS NOT NULL;
END;
GO

-- 4.16 Migración de Detalle de Compras
CREATE PROCEDURE [NUTREAM].[migrar_detalle_compras]
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO [NUTREAM].[DetalleCompra] (
        nro_compra, cod_producto, cantidad_prod_compra, precio_unitario_prod_compra
    )
    SELECT 
        m.Compra_Nro_Compra,
        RTRIM(LTRIM(m.Producto_Cod_Producto)),
        m.Detalle_Compra_Cantidad_Prod_Compra,
        m.Detalle_Compra_Precio_Unitario_Prod_Compra
    FROM gd_esquema.Maestra m
    WHERE m.Compra_Nro_Compra IS NOT NULL 
      AND m.Producto_Cod_Producto IS NOT NULL;
END;
GO

-- 4.17 Migración de Alquileres
CREATE PROCEDURE [NUTREAM].[migrar_alquileres]
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO [NUTREAM].[Alquiler] (
        nro_alquiler, fecha_inicio_alquiler, fecha_fin_pactada_alquiler, 
        fecha_devolucion_real_alquiler, importe_total_alquiler, 
        cliente_id, empleado_id, nro_serie_bici_alquiler, 
        forma_pago_id, estado_alquiler_id
    )
    SELECT DISTINCT 
        m.Alquiler_Nro_Alquiler,
        m.Alquiler_Fecha_Inicio_Alquiler,
        m.Alquiler_Fecha_Fin_Pactada_Alquiler,
        m.Alquiler_Fecha_Devolucion_Real_Alquiler,
        m.Alquiler_Importe_Total_Alquiler,
        c.cliente_id,
        e.empleado_id,
        RTRIM(LTRIM(m.Bicicleta_Alquiler_Nro_Serie_Bici_Alquiler)),
        fp.forma_pago_id,
        ea.estado_alquiler_id
    FROM gd_esquema.Maestra m
    JOIN [NUTREAM].[Cliente] c 
        ON c.dni_cliente = RTRIM(LTRIM(m.Cliente_Dni_Cliente))
       AND c.email_cliente = RTRIM(LTRIM(m.Cliente_Email_Cliente))
    JOIN [NUTREAM].[Empleado] e 
        ON e.dni_empleado = RTRIM(LTRIM(m.Empleado_Dni_Empleado))
    JOIN [NUTREAM].[FormaPago] fp 
        ON fp.forma_pago = RTRIM(LTRIM(m.Forma_Pago_Forma_Pago))
    JOIN [NUTREAM].[EstadoAlquiler] ea 
        ON ea.estado_alquiler = RTRIM(LTRIM(m.Estado_Alquiler_Estado_Alquiler))
    WHERE m.Alquiler_Nro_Alquiler IS NOT NULL;
END;
GO

-- 4.18 Migración de Reparaciones (Cabecera)
CREATE PROCEDURE [NUTREAM].[migrar_reparaciones]
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO [NUTREAM].[Reparacion] (
        nro_reparacion, numero_serie_bici_reparacion, fecha_ingreso_reparacion, 
        fecha_entrega_estimada_reparacion, fecha_entrega_real_reparacion, 
        diagnostico_reparacion, precio_mano_obra_reparacion, 
        precio_repuestos_reparacion, precio_total_reparacion, 
        local_id, cliente_id, empleado_id, modelo_bicicleta_id, estado_reparacion_id
    )
    SELECT DISTINCT 
        m.Reparacion_Nro_Reparacion,
        RTRIM(LTRIM(m.Reparacion_Numero_Serie_Bici_Reparacion)),
        m.Reparacion_Fecha_Ingreso_Reparacion,
        m.Reparacion_Fecha_Entrega_Estimada_Reparacion,
        m.Reparacion_Fecha_Entrega_Real_Reparacion,
        RTRIM(LTRIM(m.Reparacion_Diagnostico_Reparacion)),
        m.Reparacion_Precio_Mano_Obra_Reparacion,
        m.Reparacion_Precio_Repuestos_Reparacion,
        m.Reparacion_Precio_Total_Reparacion,
        loc.local_id,
        c.cliente_id,
        e.empleado_id,
        mb.modelo_bicicleta_id,
        er.estado_reparacion_id
    FROM gd_esquema.Maestra m
    JOIN [NUTREAM].[Local] loc 
        ON loc.nombre_local = RTRIM(LTRIM(m.Local_Nombre_Local))
    JOIN [NUTREAM].[Cliente] c 
        ON c.dni_cliente = RTRIM(LTRIM(m.Cliente_Dni_Cliente))
       AND c.email_cliente = RTRIM(LTRIM(m.Cliente_Email_Cliente))
    JOIN [NUTREAM].[Empleado] e 
        ON e.dni_empleado = RTRIM(LTRIM(m.Empleado_Dni_Empleado))
    JOIN [NUTREAM].[ModeloBicicleta] mb 
        ON mb.modelo_bicicleta = RTRIM(LTRIM(m.Modelo_Bicicleta_Modelo_Bicicleta))
    JOIN [NUTREAM].[EstadoReparacion] er 
        ON er.estado_reparacion = RTRIM(LTRIM(m.Estado_Reparacion_Estado_Reparacion))
    WHERE m.Reparacion_Nro_Reparacion IS NOT NULL;
END;
GO

-- 4.19 Migración de Detalle de Reparaciones
CREATE PROCEDURE [NUTREAM].[migrar_detalle_reparaciones]
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO [NUTREAM].[DetalleReparacion] (
        nro_reparacion, cod_repuesto, cantidad_repuesto, 
        precio_unitario_repuesto, subtotal_repuesto
    )
    SELECT 
        m.Reparacion_Nro_Reparacion,
        RTRIM(LTRIM(m.Repuesto_Cod_Repuesto)),
        m.Detalle_Reparacion_Cantidad_Repuesto,
        m.Detalle_Reparacion_Precio_Unitario_Repuesto,
        m.Detalle_Reparacion_Subtotal_Repuesto
    FROM gd_esquema.Maestra m
    WHERE m.Reparacion_Nro_Reparacion IS NOT NULL 
      AND m.Repuesto_Cod_Repuesto IS NOT NULL;
END;
GO

/* ============================================================================
   5. BLOQUE DE EJECUCIÓN TRANSACCIONAL
   ============================================================================ */
BEGIN TRY
    BEGIN TRANSACTION;

    PRINT '>> [1/19] Migrando Localidades...';
    EXEC [NUTREAM].[migrar_localidades];

    PRINT '>> [2/19] Migrando Catálogos Generales...';
    EXEC [NUTREAM].[migrar_catalogos];

    PRINT '>> [3/19] Migrando Locales...';
    EXEC [NUTREAM].[migrar_locales];

    PRINT '>> [4/19] Migrando Clientes...';
    EXEC [NUTREAM].[migrar_clientes];

    PRINT '>> [5/19] Migrando Empleados...';
    EXEC [NUTREAM].[migrar_empleados];

    PRINT '>> [6/19] Migrando Proveedores...';
    EXEC [NUTREAM].[migrar_proveedores];

    PRINT '>> [7/19] Migrando Modelos de Bicicleta...';
    EXEC [NUTREAM].[migrar_modelos_bicicleta];

    PRINT '>> [8/19] Migrando Repuestos...';
    EXEC [NUTREAM].[migrar_repuestos];

    PRINT '>> [9/19] Migrando Catálogo Base de Productos...';
    EXEC [NUTREAM].[migrar_productos];

    PRINT '>> [10/19] Migrando Bicicletas para la Venta...';
    EXEC [NUTREAM].[migrar_bicicletas_venta];

    PRINT '>> [11/19] Migrando Accesorios...';
    EXEC [NUTREAM].[migrar_accesorios];

    PRINT '>> [12/19] Migrando Flota de Bicicletas de Alquiler...';
    EXEC [NUTREAM].[migrar_bicicletas_alquiler];

    PRINT '>> [13/19] Migrando Cabeceras de Ventas...';
    EXEC [NUTREAM].[migrar_ventas];

    PRINT '>> [14/19] Migrando Detalle de Ventas...';
    EXEC [NUTREAM].[migrar_detalle_ventas];

    PRINT '>> [15/19] Migrando Cabeceras de Compras...';
    EXEC [NUTREAM].[migrar_compras];

    PRINT '>> [16/19] Migrando Detalle de Compras...';
    EXEC [NUTREAM].[migrar_detalle_compras];

    PRINT '>> [17/19] Migrando Alquileres...';
    EXEC [NUTREAM].[migrar_alquileres];

    PRINT '>> [18/19] Migrando Cabeceras de Reparaciones...';
    EXEC [NUTREAM].[migrar_reparaciones];

    PRINT '>> [19/19] Migrando Detalle de Reparaciones...';
    EXEC [NUTREAM].[migrar_detalle_reparaciones];

    COMMIT TRANSACTION;
    PRINT '>> ==============================================================';
    PRINT '>> MIGRACIÓN TRANSACCIONAL COMPLETADA EXITOSAMENTE [NUTREAM]';
    PRINT '>> ==============================================================';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    PRINT '>> ERROR DURANTE LA MIGRACIÓN:';
    THROW;
END CATCH;
GO

/* ============================================================================
   6. CREACIÓN DE ÍNDICES DE RENDIMIENTO (Claves Foráneas y Búsquedas Frecuentes)
   ============================================================================ */
PRINT '>> Creando índices no agrupados para optimización de consultas...';

CREATE NONCLUSTERED INDEX IX_Venta_Cliente ON [NUTREAM].[Venta](cliente_id);
CREATE NONCLUSTERED INDEX IX_Venta_Empleado ON [NUTREAM].[Venta](empleado_id);
CREATE NONCLUSTERED INDEX IX_Venta_Local ON [NUTREAM].[Venta](local_id);
CREATE NONCLUSTERED INDEX IX_DetalleVenta_Venta ON [NUTREAM].[DetalleVenta](nro_venta);
CREATE NONCLUSTERED INDEX IX_DetalleVenta_Producto ON [NUTREAM].[DetalleVenta](cod_producto);

CREATE NONCLUSTERED INDEX IX_Alquiler_Cliente ON [NUTREAM].[Alquiler](cliente_id);
CREATE NONCLUSTERED INDEX IX_Alquiler_Empleado ON [NUTREAM].[Alquiler](empleado_id);
CREATE NONCLUSTERED INDEX IX_Alquiler_Bici ON [NUTREAM].[Alquiler](nro_serie_bici_alquiler);

CREATE NONCLUSTERED INDEX IX_Reparacion_Cliente ON [NUTREAM].[Reparacion](cliente_id);
CREATE NONCLUSTERED INDEX IX_Reparacion_Empleado ON [NUTREAM].[Reparacion](empleado_id);
CREATE NONCLUSTERED INDEX IX_Reparacion_Local ON [NUTREAM].[Reparacion](local_id);
CREATE NONCLUSTERED INDEX IX_DetalleReparacion_Reparacion ON [NUTREAM].[DetalleReparacion](nro_reparacion);
CREATE NONCLUSTERED INDEX IX_DetalleReparacion_Repuesto ON [NUTREAM].[DetalleReparacion](cod_repuesto);

CREATE NONCLUSTERED INDEX IX_Compra_Proveedor ON [NUTREAM].[Compra](proveedor_id);
CREATE NONCLUSTERED INDEX IX_Compra_Local ON [NUTREAM].[Compra](local_id);
CREATE NONCLUSTERED INDEX IX_DetalleCompra_Compra ON [NUTREAM].[DetalleCompra](nro_compra);
CREATE NONCLUSTERED INDEX IX_DetalleCompra_Producto ON [NUTREAM].[DetalleCompra](cod_producto);

PRINT '>> Índices creados exitosamente.';
GO
