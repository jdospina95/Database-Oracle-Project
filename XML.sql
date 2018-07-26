CREATE DIRECTORY DIRECTORIO AS 'C:\alumnos\JuanDavidOspina';
GRANT read, write ON DIRECTORY DIRECTORIO TO jdospina95


CREATE OR REPLACE PROCEDURE generarxmlfactura(v_numorden int) IS

v_xmldoc CLOB;

BEGIN

SELECT XMLElement("Ordenes_Compras", 
        XMLElement("Cliente",
            XMLAttributes(cliente.NIT as "ClienteID"),
            XMLElement("Nombre", cliente.NOMBRE),
            XMLElement("Apellido", cliente.APELLIDO),
            XMLElement("TipoCliente", tipocliente.TIPOCLIENTE),
            XMLElement("Telefono", cliente.telefono),
            XMLElement("Datos_Contacto", cliente.datoscontacto),
            XMLElement("Direccion_Completa",
                XMLElement("Direccion", cliente.correo),
                XMLElement("Ciudad", ciudad.ciudad),
                XMLElement("Departamento", departamento.departamento),
                XMLElement("Pais", pais.pais))),
        XMLElement("Orden", 
            XMLAttributes(orden.numorden as "NumOrden", orden.fecha as "Fecha"),
            XMLElement("Items",
                XMLElement("Item",
                    XMLConcat(
                        XMLSequence(Cursor(
                            SELECT articulosfacturados.idproducto as "IDProducto",
                                   producto.nombreproducto "Nombre_Producto", 
                                   articulosfacturados.cantidad "Cantidad",
                                   articulosfacturados.preciounitario "Precio"
                                   FROM articulosfacturados join producto on (articulosfacturados.idproducto = producto.idproducto)
                                                            join factura on (factura.numfactura = articulosfacturados.numfactura)
                                   WHERE factura.numorden = v_numorden 
                        ))))))).getClobVal()
INTO v_xmldoc

FROM cliente join tipocliente on (cliente.idtipocliente = tipocliente.idtipocliente) join ciudad on (cliente.idciudad = ciudad.idciudad) 
             join departamento on (ciudad.iddepartamento = departamento.iddepartamento) join pais on (departamento.idpais = pais.idpais)
             join orden on (orden.nitcliente = cliente.nit)
WHERE orden.numorden = v_numorden;

dbms_xslprocessor.clob2file(v_xmldoc, 'DIRECTORIO', 'output.xml');

END;

CREATE OR REPLACE  FUNCTION verificarCliente(v_numOrden int) RETURN int AS
resultado int;
BEGIN
resultado := 0;
SELECT cliente.nit INTO resultado FROM cliente JOIN orden ON orden.numorden = v_numOrden AND cliente.nit = orden.nitcliente;
RETURN resultado;
END;

CREATE OR REPLACE PROCEDURE cargarXML IS
v_numeroOrden int;
BEGIN
SELECT numorden_seq.NEXTVAL INTO v_numeroOrden FROM dual;

INSERT INTO pedido_xml VALUES (XMLTYPE(bfilename('DIRECTORIO', 'Orden.xml'),nls_charset_id('AL32UTF8')));
	INSERT INTO orden(numorden,nitcliente,estado,fecha,fechaentregar) 
	SELECT 
	v_numeroOrden,
	(SELECT extractValue(OBJECT_VALUE,'/orden/NIT')"nitcliente" FROM pedido_xml),
	'SinFacturar',
	(SELECT CURRENT_DATE FROM dual)"fecha",
	(SELECT SYSDATE + 1 FROM dual)"fechaentregar"
    FROM dual;
    INSERT INTO productosordenados(numorden,idproducto,cantidad) SELECT
    v_numeroOrden, z.idproducto, z.cantidad FROM pedido_xml, XMLTABLE('/orden'
        PASSING OBJECT_VALUE
        COLUMNS
            Productos xmltype PATH '/orden/productos') x,
            XMLTABLE('/productos'
        PASSING x.Productos
        COLUMNS
            producto xmltype PATH '/productos/Producto') y,
            XMLTABLE('/Producto'
        PASSING y.producto
        COLUMNS
            cantidad int path '/Producto/cantidad',
            idproducto int path '/Producto/idproducto') z;
DELETE FROM pedido_xml;
END;