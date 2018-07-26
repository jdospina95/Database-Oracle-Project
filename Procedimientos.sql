-- ********************************* FACTURACION *********************************

CREATE SEQUENCE idFactura_seq START WITH 1;

CREATE OR REPLACE PROCEDURE facturacion(v_numeroOrden int, v_idProducto int, v_CantidadOrdenada int, v_idcliente char) IS
    v_fecha date;
    v_valor numeric(15,3);
    v_id int;
    v_fecha2 date;
BEGIN
    SELECT CURRENT_DATE INTO v_fecha FROM dual;
    SELECT SYSDATE + 1 INTO v_fecha2 FROM dual;
    SELECT valor INTO v_valor FROM Producto WHERE idProducto = v_idProducto;
    SELECT idFactura_seq.NEXTVAL INTO v_id FROM dual;
    INSERT INTO ArticulosFacturados VALUES (v_id, v_idProducto, v_CantidadOrdenada, v_valor, ((v_CantidadOrdenada * v_valor)*0.16), (v_CantidadOrdenada * v_valor)+((v_CantidadOrdenada * v_valor)*0.16));
    INSERT INTO Factura VALUES (v_id, v_idCliente, v_fecha, v_numeroOrden);
    UPDATE ORDEN SET FECHAENTREGAR = v_fecha2 WHERE NUMORDEN = v_numeroOrden;
    commit;
END;

--validarcatalogo() si hay facturacion()
--					  si no insert en no stock
--Procedimiento que actualiza las tablas segun los productos ordenados
CREATE OR REPLACE PROCEDURE validarcatalogo(numeroOrden int, v_idProducto int, Cantidad int, idcliente char) IS
    v_cantidaDisponible int;
BEGIN
    SELECT cantidadDisponible INTO v_cantidaDisponible FROM Producto WHERE idProducto = v_idProducto;
    IF (Cantidad > v_cantidaDisponible) THEN
        INSERT INTO NOSTOCK VALUES (numeroOrden, v_idProducto, Cantidad-v_cantidaDisponible);
        UPDATE Producto SET cantidadDisponible = 0 WHERE idProducto = v_idProducto;
        UPDATE ORDEN SET Estado = 'Facturado' WHERE numOrden = numeroOrden;
        facturacion(numeroOrden, v_idProducto, v_cantidaDisponible, idcliente);
    ELSIF (Cantidad < v_cantidaDisponible) THEN
        UPDATE PRODUCTO SET cantidadDisponible = v_cantidaDisponible-Cantidad WHERE idProducto = v_idProducto;
        UPDATE ORDEN SET Estado = 'Facturado' WHERE numOrden = numeroOrden;
        facturacion(numeroOrden, v_idProducto, Cantidad, idcliente);
    ELSIF (Cantidad = v_cantidaDisponible) THEN
        UPDATE PRODUCTO SET cantidadDisponible = 0 WHERE idProducto = v_idProducto;
        UPDATE ORDEN SET Estado = 'Facturado' WHERE numOrden = numeroOrden;
        facturacion(numeroOrden, v_idProducto, Cantidad, idcliente);
    END IF;
    commit;
EXCEPTION
WHEN OTHERS THEN
   dbms_output.put_line('No se pudo validar catalogo');
END;

-- Procedimiento el cual realiza la facturacion de las ordenes a partir de los productos disponibles
CREATE OR REPLACE PROCEDURE consultarpedidosrecibidos IS
    numeropedidoa int;
    idproductoa int;
    cantidada int;
    idcliente char(13);
	cursor curs is SELECT productosordenados.numorden,
                          productosordenados.idproducto,
                          productosordenados.cantidad,
                          orden.NITCliente
                    FROM productosordenados join orden on (productosordenados.numorden = orden.numOrden)
                    WHERE orden.estado = 'SinFacturar'; --Consultar pedidos sin facturar
BEGIN
    OPEN curs;
    LOOP
        FETCH curs INTO numeropedidoa, idproductoa, cantidada, idcliente;
        EXIT WHEN curs%NOTFOUND;
        validarcatalogo(numeropedidoa, idproductoa, cantidada, idcliente); --Por cada iteracion manda la informacion de cada uno de los productos que estan sin facturar
    END LOOP;
EXCEPTION
WHEN OTHERS THEN
   dbms_output.put_line('No existen ordenes sin facturar');
END;

--Procedimiento que crea un xml a partir de las ordenes del cliente dado
CREATE OR REPLACE PROCEDURE generarxmlcompras(v_idCliente) IS
    cursor curs is SELECT 
BEGIN

-- ********************************* CREAR PERFIL CLIENTE *********************************
CREATE OR REPLACE PROCEDURE ingresarCliente(v_NIT char, v_Nombre varchar2,  v_apellido varchar2, v_idciudad int, v_correo varchar2, v_datoscontacto VARCHAR2, v_IDTIPOCLIENTE INT, v_TELEFONO INT) IS
BEGIN
    INSERT INTO CLIENTE VALUES (v_NIT, v_Nombre, v_apellido, v_idciudad, v_correo, v_datoscontacto, v_IDTIPOCLIENTE, v_TELEFONO);
    commit;
EXCEPTION
WHEN OTHERS THEN
   dbms_output.put_line('Algun dato se ingreso de forma incorrecta, revisar datos ingresados');
END;

-- ********************************* LISTAR CLIENTES *********************************
create or replace PROCEDURE listarClientes IS
    cursor curs is SELECT * FROM CLIENTE;
    cliente_rec  curs%ROWTYPE;
BEGIN
    dbms_output.put_line('          ***********************   CLIENTES   ***********************');
    OPEN curs;
    LOOP
        FETCH curs INTO cliente_rec;
        EXIT WHEN curs%NOTFOUND;
        dbms_output.put_line(cliente_rec.NIT || ' ' ||  nvl(cliente_rec.NOMBRE, '') || ' ' || 
                                                        nvl(cliente_rec.APELLIDO, '') || ' ' ||
                                                        nvl(cliente_rec.IDCIUDAD, '') || ' ' ||
                                                        nvl(cliente_rec.CORREO, '') || ' ' ||
                                                        nvl(cliente_rec.DATOSCONTACTO, '') || ' ' ||
                                                        nvl(cliente_rec.IDTIPOCLIENTE, '') || ' ' ||
                                                        nvl(cliente_rec.TELEFONO, ''));
    END LOOP;
EXCEPTION
WHEN OTHERS THEN
   dbms_output.put_line('Cliente mal ingresado, no se puede listar');     
END;

-- ********************************* MODIFICAR CLIENTE *********************************
CREATE OR REPLACE PROCEDURE modificarCliente(v_NIT char, v_Nombre varchar2,  v_apellido varchar2, v_idciudad int, v_correo varchar2, v_datoscontacto VARCHAR2, v_IDTIPOCLIENTE INT, v_TELEFONO INT) IS
BEGIN
    UPDATE CLIENTE SET NOMBRE = v_Nombre, APELLIDO = v_apellido, IDCIUDAD = v_idciudad, CORREO = v_correo, DATOSCONTACTO = v_datoscontacto, IDTIPOCLIENTE = v_IDTIPOCLIENTE, TELEFONO = v_TELEFONO WHERE CLIENTE.NIT = v_NIT;
    commit;
EXCEPTION
WHEN OTHERS THEN
   dbms_output.put_line('Algun dato se ingreso de forma incorrecta, revisar datos ingresados');
END;

-- ********************************* INGRESAR PROVEEDOR *********************************
CREATE OR REPLACE PROCEDURE ingresarProveedor(v_idProveedor int, v_Proveedor varchar2, v_idCiudad int) IS
BEGIN
    INSERT INTO PROVEEDORES VALUES (v_idProveedor, v_Proveedor, v_idCiudad);
    commit;
EXCEPTION
WHEN OTHERS THEN
   dbms_output.put_line('Algun dato se ingreso de forma incorrecta, revisar datos ingresados');
END;

-- ********************************* INGRESAR PRODUCTO *********************************
CREATE OR REPLACE PROCEDURE ingresarProducto(v_idProducto int, v_Producto varchar2, v_valor numeric, v_idTipoProducto int, v_cantidaDisponible int) IS
BEGIN
    INSERT INTO PRODUCTO VALUES (v_idProducto, v_Producto, v_valor, v_idTipoProducto, v_cantidaDisponible);
    commit;
EXCEPTION
WHEN OTHERS THEN
   dbms_output.put_line('Algun dato se ingreso de forma incorrecta, revisar datos ingresados');
END;

-- ********************************* REALIZAR ORDEN *********************************
CREATE SEQUENCE numorden_seq START WITH 1;

CREATE OR REPLACE PROCEDURE realizarOrden(v_NIT varchar2, v_idProducto int, v_cantidad int) IS
    v_fecha date;
    v_numeroOrden int;
BEGIN
    SELECT numorden_seq.NEXTVAL INTO v_numeroOrden FROM dual;
    SELECT CURRENT_DATE INTO v_fecha FROM dual;
    INSERT INTO ORDEN VALUES (v_numeroOrden, v_NIT, 'SinFacturar', v_fecha, v_fecha);
    INSERT INTO PRODUCTOSORDENADOS VALUES (v_numeroOrden, v_idProducto, v_cantidad);
    commit;
EXCEPTION
WHEN OTHERS THEN
   dbms_output.put_line('Algun dato se ingreso de forma incorrecta, revisar datos ingresados');
END;

-- ********************************* AGREGAR CANTIDAD PRODUCTO *********************************
CREATE OR REPLACE PROCEDURE agregarCantidad(v_idProducto int, v_cantidad int) IS
    v_cantidadTiene int;
BEGIN
    SELECT CANTIDADDISPONIBLE INTO v_cantidadTiene FROM PRODUCTO WHERE IDPRODUCTO = v_idProducto;
    UPDATE PRODUCTO SET CANTIDADDISPONIBLE = v_cantidadTiene + v_cantidad WHERE IDPRODUCTO = v_idProducto;
    commit;
EXCEPTION
WHEN OTHERS THEN
   dbms_output.put_line('Se ingreso una cantidad erronea');
END;