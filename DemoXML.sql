/*CREACION DE ESTRUCTURAS PARA EJECUTAR EL EJEMPLO*/

create table DESPACHO (ID_DESPACHO number ,FECHA date,ID_EMPRESA_ENVIO number ,ID_EMPRESA_DESTINO number,VALOR number,ID_CAMION number);
create table PRODUCTO_X_DESPACHO (ID_DESPACHO number, ID_PRODUCTO number, CANTIDAD number, VALOR_UNITARIO number, FECHA_VENCIMIENTO date);
create table PRODUCTO (ID_PRODUCTO number, NOMBRE VARCHAR2(30), TIPO_EMPAQUE VARCHAR(60));

INSERt INTO PRODUCTO VALUES (45,'CAFE', 'BOLSA');
INSERt INTO PRODUCTO VALUES (49,'LECHE', 'BOTELLA');
create table AUTORIZACION (ID_AUTORIZACION NUMBER, ID_DESPACHO NUMBER, FECHA_INICIO DATE, FECHA_FIN DATE);
create table CAMION (ID_CAMION NUMBER, PLACA VARCHAR(5));
INSERT INTO CAMION VALUES (5,'HYL93');


/* CREAR USANDO SYS*/
CREATE DIRECTORY DIR_DEMO AS '/oracle/directorios/';
GRANT read, write ON DIRECTORY DIR_DEMO TO javeriana

/* CREAR USANDO USUARIO NORMAL*/

DROP TABLE pedido_xml;
CREATE TABLE pedido_xml OF XMLType;

INSERT INTO pedido_xml VALUES (XMLTYPE(
	bfilename('DIR_DEMO', 'pedidos.xml'),nls_charset_id('AL32UTF8')));
 
COMMIT;

INSERT INTO DESPACHO (ID_DESPACHO,FECHA,ID_EMPRESA_ENVIO,ID_EMPRESA_DESTINO,VALOR,ID_CAMION)
SELECT 
 (SELECT extractValue(OBJECT_VALUE, '/despacho/id_despacho') "ID_DESPACHO" FROM pedido_xml)
, TO_DATE((SELECT extractValue(OBJECT_VALUE, '/despacho/fecha_despacho') "FECHA_DESPACHO" FROM pedido_xml), 'DD/MM/YYYY')
, (SELECT extractValue(OBJECT_VALUE, '/despacho/empresa_envio') "ID_EMPRESA_ENVIO" FROM pedido_xml)
, (SELECT extractValue(OBJECT_VALUE, '/despacho/empresa_destino') "ID_EMPRESA_DESTINO" FROM pedido_xml)
, (SELECT extractValue(OBJECT_VALUE, '/despacho/valor_total') "VALOR" FROM pedido_xml)
, (SELECT extractValue(OBJECT_VALUE, '/despacho/id_camion') "ID_CAMION" FROM pedido_xml)
FROM dual;

COMMIT;


select * from pedido_xml;

INSERT INTO PRODUCTO_X_DESPACHO (ID_DESPACHO, ID_PRODUCTO, CANTIDAD, VALOR_UNITARIO, FECHA_VENCIMIENTO)
SELECT (SELECT extractValue(OBJECT_VALUE, '/despacho/id_despacho') "ID_DESPACHO" FROM pedido_xml), z.id_producto, z.cantidad, z.valor_unitario, TO_DATE(z.fecha_vencimiento, 'DD/MM/YYYY') from pedido_xml, XMLTABLE('/despacho'
      PASSING OBJECT_VALUE
      COLUMNS 
        id_despacho number PATH '/despacho/id_despacho'
        , productos xmltype PATH '/despacho/productos') x
      , XMLTABLE('/productos'
        PASSING x.productos
        COLUMNS
          producto xmltype PATH '/productos/producto') y
      , XMLTABLE('/producto'
        PASSING y.producto
        columns
          id_producto number path '/producto/id_producto'
          , cantidad number path '/producto/cantidad'
          , valor_unitario number path '/producto/valor_unitario'
          , fecha_vencimiento varchar(100) path '/producto/fecha_vencimiento') z;

COMMIT;

INSERT INTO AUTORIZACION (ID_AUTORIZACION, ID_DESPACHO, FECHA_INICIO, FECHA_FIN)
SELECT 
	1
	, (SELECT extractValue(OBJECT_VALUE, '/despacho/id_despacho') "ID_DESPACHO" FROM pedido_xml)
	, CURRENT_DATE
	, NEXT_DAY(CURRENT_DATE, 'DOMINGO')
FROM dual;

COMMIT;


CREATE OR REPLACE PROCEDURE generarxmlfactura(v_numorden) IS

v_xmldoc CLOB;

BEGIN

SELECT XMLELEMENT("autorizacion", 
	XMLELEMENT("id", A.ID_AUTORIZACION)
	, XMLELEMENT("desde", A.FECHA_INICIO)
	, XMLELEMENT("hasta", A.FECHA_FIN)
	, XMLELEMENT("despacho", A.ID_DESPACHO)
	, XMLELEMENT("camion", TRIM(C.PLACA))
	, XMLELEMENT("productos", 
		XMLCONCAT(
			XMLSEQUENCE(CURSOR(
				SELECT PROD.ID_PRODUCTO "producto", TRIM(PROD.TIPO_EMPAQUE) "empaque" 
				FROM PRODUCTO_X_DESPACHO P
				JOIN DESPACHO D ON P.ID_DESPACHO = D.ID_DESPACHO
				JOIN PRODUCTO PROD ON P.ID_PRODUCTO = PROD.ID_PRODUCTO
				WHERE P.ID_DESPACHO = A.ID_DESPACHO))
      )
    )
  ).getClobVal()
INTO v_xmldoc
FROM AUTORIZACION A
JOIN DESPACHO D ON A.ID_DESPACHO = D.ID_DESPACHO
JOIN CAMION C ON D.ID_CAMION = C.ID_CAMION
WHERE A.ID_AUTORIZACION = 1;

dbms_xslprocessor.clob2file(v_xmldoc, 'DIR_DEMO', 'output.xml');

END;
