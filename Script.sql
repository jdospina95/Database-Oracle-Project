BEGIN TRANSACTION;

CREATE TABLE TIPOPRODUCTO(
    IDTIPOPRODUCTO INT PRIMARY KEY,
    TIPOPRODUCTO VARCHAR2(30)
);

CREATE TABLE PAIS(
    IDPAIS INT PRIMARY KEY,
    PAIS VARCHAR2(30)
);

CREATE TABLE DEPARTAMENTO(
    IDDEPARTAMENTO INT PRIMARY KEY,
    DEPARTAMENTO VARCHAR2(30),
    IDPAIS INT REFERENCES PAIS
);

CREATE TABLE CIUDAD(
    IDCIUDAD INT PRIMARY KEY,
    CIUDAD VARCHAR2(30),
    IDDEPARTAMENTO INT REFERENCES DEPARTAMENTO
);

CREATE TABLE PROVEEDORES(
    IDPROVEEDOR INT PRIMARY KEY,
    PROVEEDOR VARCHAR2(30),
    IDCIUDAD INT REFERENCES CIUDAD
);

CREATE TABLE TIPOCLIENTE(
    IDTIPOCLIENTE INT PRIMARY KEY,
    TIPOCLIENTE CHAR(20)
);

CREATE TABLE PRODUCTO(
    IDPRODUCTO INT PRIMARY KEY NOT NULL,
    NOMBREPRODUCTO VARCHAR2(20),
    VALOR NUMERIC(15,3),
    IDTIPOPRODUCTO INT REFERENCES TIPOPRODUCTO,
    CANTIDADDISPONIBLE INT
);

CREATE TABLE CATALOGO(
    NUMEROCATALOGO INT PRIMARY KEY,
    IDPRODUCTO INT REFERENCES PRODUCTO,
    IDPROVEEDOR INT REFERENCES PROVEEDORES
);

CREATE TABLE CLIENTE(
    NIT CHAR(13) PRIMARY KEY,
    NOMBRE VARCHAR2(20),
    APELLIDO VARCHAR2(20),
    IDCIUDAD INT REFERENCES CIUDAD,
    CORREO VARCHAR2(50),
    DATOSCONTACTO VARCHAR2(100),
    IDTIPOCLIENTE INT REFERENCES TIPOCLIENTE,
    TELEFONO INT
);

CREATE TABLE ARTICULOSFACTURADOS(
    NUMFACTURA INT NOT NULL,
    IDPRODUCTO INT REFERENCES PRODUCTO,
    CANTIDAD INT,
    PRECIOUNITARIO NUMERIC(15,3),
    IVA NUMERIC(15,3),
    PRECIOTOTAL NUMERIC(15,3),
    CONSTRAINT factura_pk PRIMARY KEY (NUMFACTURA)
);

CREATE TABLE ORDEN(
    NUMORDEN INT PRIMARY KEY NOT NULL,
    NITCLIENTE CHAR(13) REFERENCES CLIENTE,
    ESTADO VARCHAR2(30),
    FECHA DATE,
    FECHAENTREGAR DATE
);

CREATE TABLE FACTURA(
    NUMFACTURA INT NOT NULL,
    NITCLIENTE CHAR(13) REFERENCES CLIENTE,
    FECHAFACTURA DATE,
    NUMORDEN INT REFERENCES ORDEN,
    CONSTRAINT fk_factura FOREIGN KEY (NUMFACTURA) REFERENCES ARTICULOSFACTURADOS(NUMFACTURA)
);

CREATE TABLE PRODUCTOSORDENADOS(
    NUMORDEN INT NOT NULL,
    IDPRODUCTO INT NOT NULL,
    CANTIDAD INT,
    CONSTRAINT fk_numorden FOREIGN KEY (NUMORDEN) REFERENCES ORDEN(NUMORDEN),
    CONSTRAINT fk_idproducto FOREIGN KEY (IDPRODUCTO) REFERENCES PRODUCTO(IDPRODUCTO)
);

CREATE TABLE NOSTOCK(
    NUMORDEN INT NOT NULL,
    IDPRODUCTO INT NOT NULL,
    CANTIDADNOSTOCK INT,
    CONSTRAINT fk_numorden1 FOREIGN KEY (NUMORDEN) REFERENCES ORDEN(NUMORDEN),
    CONSTRAINT fk_idproducto1 FOREIGN KEY (IDPRODUCTO) REFERENCES PRODUCTO(IDPRODUCTO)
);