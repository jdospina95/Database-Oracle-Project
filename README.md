# Database-Oracle-Project

La empresa  compras.net vende mercancía de diferent
es tipos (Ferreteros, Comestibles  y 
electrónicos)
,  las empresas 
o clientes  
descargan los catálogos 
desde el sitio web 
en
formato 
XML 
de los productos
para luego realizar los
pedido
s. Este archivo contiene el 
nombre del proveedor, tipo de producto, nombre del producto, precio de venta, cantidad 
disponible.
Una empresa 
que 
requiera generar pedidos de productos
deben 
genera
r 
un archivo xml 
que 
contiene la
información de la empresa y los productos solicitados
tomados del catálogo de 
producto
, este 
archivo es
subido a un servidor 
de compras.net  
para 
luego 
ser cargado en 
la base de datos
, esta información debe ser desagregada o distribuida en una base de 
datos 
relacional
la cual usted diseñara según los requerimientos
, una vez se cargue la información 
proveniente del xml  
se valida la existencia d
el cliente, si no existe se debe crear el cliente
los datos mínimos son nombres, nit, país, departamento, ciuda
d
,
correo, datos de contacto 
y tipo de cliente (Normal, Preferencial).
Luego
se valida la disponibilidad de productos en 
caso que no exista la existe
ncia total
de productos 
se 
debe 
genera
r
un documento 
o archivo 
xml donde se 
notifi
que 
cual
producto 
no ti
ene las existencias disponibles para 
ser entrego 
e
indica
r
el número
de orden 
y fecha
. 
Una vez se cumpla las validaciones adicionales la 
orden se almacena en la base de datos con estado en “proceso”, para luego pasar al proceso 
de facturación
.
La facturac
ión es un proceso
donde se realiza el cambio de 
los valores o cantidades 
disponibles  de  los  catálogos  descontando  los  productos  facturados
y  se  genera  la 
información de artículos con sus precios e iva 
correspondiente,
tenga en cuenta que no se 
facturaran 
los productos que fueron validados por no cumplir con el stock
.
Los datos de 
facturación son nombre cliente, teléfono, país, ciudad, departamento, fecha de factura, 
fecha de entrega y lista de artículos facturados (Nombre, código artículo, cantidad, precio
unitario, precio total, iva) 
con esta información se
genera un documento en XML.
Es 
importante tener en cuenta que todo proceso debe quedar almacenado en la base de datos 
relacional indiferente que se genere el documento en XML.
Los catálogos tienen la
siguiente información:
Código del producto, nombre producto, 
tipo de 
producto,
nombre del proveedor, ciudad 
del proveedor, precio de venta y cantidades disponibles
. Estas cantidades disponibles 
pueden variar dependiendo la cantidad de órdenes solicitadas.
Esta información esta 
almacenada en una base de datos relacional y debe ser exportada en un archivo xml. El 
formato es de libre creación.
1.
Realizar el diseño de base de datos con la distribución física (tablespaces) necesarios 
para mejorar el rendimiento 
de la base de datos
según información suministrada 
anteriormente.
El archivo generado por parte de cliente una vez verificado los datos de catálogo puede 
ser como este.
Propuesta de  XML de Pedido
<?xml version="1.0"?>
<
Ordenes_compras
>
<
Cliente 
CustomerID="GREAL">
<CompanyName>Great Lakes Food Market</CompanyName>
<ContactName>Howard Snyder</ContactName>
<ContactTitle>Marketing Manager</ContactTitle>
<Phone>(503) 555
-
7555</Phone>
<FullAddress>
<Address>
2732 Baker Blvd.</Address>
<City>Eugene</City>
<Region>OR</Region>
<PostalCode>97403</PostalCode>
<Country>USA</Country>
</FullAddress>
</
Cliente
>
<
orden_compra 
OrderNumber="99503" OrderDate="
2014
-
02
-
20">
<
Items>
<Item PartNumber="872
-
AA">
<ProductName>Lawnmower</ProductName>
<Quantity>1</Quantity>
<
Price>148.95</USPrice>
<Comment>Confirm this is electric</Comment>
</Item>
<Item PartNumber="926
-
AA">
<
ProductName>Baby Monitor</ProductName>
<Quantity>2</Quantity>
<Price>39.98</USPrice>
<ShipDate>1999
-
05
-
21</ShipDate>
</Item>
</Items>
</
orden_compra
>
<
orden_compra
OrderNumber="99505" OrderDate="
2014
-
02
-
22">
<
Items>
<Item PartNumber="456
-
NM">
<ProductName>Power Supply</ProductName>
<Quantity>1</Quantity>
<
Price>45.99</USPrice>
</Item>
</Items>
</
orden_compra
>
</
Ordenes_compras
>
1.
Procedimientos Mínimos a Crear.
•
Para la exportación del catálogo debe existir un procedimiento en pl sql que 
genere el archivo XML para tal fin.
•
Debe existir un procedimiento que cargue el archivo XML de pedido y lo almacene 
en la base de datos relacional
•
Realizar función o procedimiento
que permita validar si existe o no la cantidad de 
unidades disponibles por cada producto de la orden de compra
•
Realizar función o procedimiento que generar archivo xml cuando no exista la 
cantidad de unidades disponibles por cada producto de la orden de c
ompra
•
Realizar procedimiento para que genere la facturación.
•
Realizar procedimiento para que genere el archivo xml después de facturado el 
producto.
Todos los procedimientos deben manejar transacciones
y ser verificados de que cumplen 
un eficiente plan de 
ejecución
