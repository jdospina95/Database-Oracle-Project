CREATE TABLE TipoCliente(
    TipoCliente_id int PRIMARY KEY,
    TipoCliente varchar(20)
);

CREATE TABLE Cliente(
    Cliente_id char(13) PRIMARY KEY,
    Nombre varchar(30),
    TipoCliente_id int REFERENCES TipoCliente
);

CREATE TABLE TipoProducto(
    TipoProducto_id int PRIMARY KEY,
    Tipo_Producto varchar(30)
);

CREATE TABLE Producto(
    Producto_id int PRIMARY KEY,
    Nombre varchar(30),
    TipoProducto_id int REFERENCES TipoProducto
);

CREATE TABLE Proveedor(
    Proveedor_id int PRIMARY KEY,
    Proveedor varchar(30)
);

CREATE TABLE Ciudad(
    Ubicacion_id int PRIMARY KEY,
    Ciudad varchar(30),
    Departamento_id int,
    Departamento varchar(30),
    Pais_id int,
    Pais varchar(30)
);

CREATE TABLE Tiempo(
    Tiempo_id date PRIMARY KEY,
    Dia int,
    Semana int,
    Mes varchar(30),
    Year_ int
);

CREATE TABLE Orden_Fact(
    Orden_id int PRIMARY KEY,
    Producto_id int REFERENCES Producto,
    Tiempo_id date REFERENCES Tiempo,
    Proveedor_id int REFERENCES Proveedor,
    Ubicacion_id int REFERENCES Ciudad,
    Cliente_id char(13) REFERENCES Cliente,
    Cantidad_Producto int,
    Precio_Orden numeric(15,3)
);

DECLARE @FECHA DATE, @ITEM INT, @FECHAf DATE
SET @FECHA = '20160101'
SET @FECHAf= '20170101'

WHILE (@FECHA <= @FECHAf)
begin
INSERT INTO [dbo].[Tiempo] (Tiempo_id, Dia, Semana, Mes, Year_) VALUES( @fecha, DAY(@fecha) , dateparT(WW,@fecha), MONTH (@fecha), YEAR(@fecha))
set @fecha = dateadd(dd,1, @fecha )
end

select * from [Tiempo]

select orden.numorden, producto.idproducto, orden.fecha, proveedores.idproveedor, ciudad.idciudad, cliente.nit, productosordenados.cantidad, articulosfacturados.preciototal
from cliente join orden on (cliente.nit = orden.nitcliente) join ciudad on (cliente.idciudad = ciudad.idciudad) join productosordenados on (orden.numorden = productosordenados.numorden) join producto on 
(productosordenados.idproducto = producto.idproducto) join catalogo on (producto.idproducto = catalogo.idproducto) join PROVEEDORES on (catalogo.idproveedor = proveedores.idproveedor) 
join articulosfacturados on (producto.idproducto = articulosfacturados.idproducto);