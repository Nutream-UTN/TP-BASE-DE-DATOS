CREATE TABLE Localidad (
    localidad_id INT IDENTITY(1,1) NOT NULL,
    nombre_localidad VARCHAR(255) NOT NULL,
    provincia VARCHAR(255) NOT NULL,

    CONSTRAINT PK_Localidad PRIMARY KEY (localidad_id)
);