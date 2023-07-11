USE Northwind;

/*EJERCICIO 1
Selecciona todos los campos de los productos, que pertenezcan a los proveedores con códigos: 1, 3, 7, 8 y 9, que tengan stock en el almacén,
y al mismo tiempo que sus precios unitarios estén entre 50 y 100.
Por último, ordena los resultados por código de proveedor de forma ascendente.*/

/*Se ha unido la tabla products con supliers porque se necesitan datos de las dos tablas, y se han pasado ciertas condiciones con Where.
Por último, se han ordenado los resultados como indica el ejercicio*/

SELECT *
	FROM `products`
	INNER JOIN `suppliers` ON `products`.`supplier_id` = `suppliers`.`supplier_id`
	WHERE  `suppliers`.`supplier_id` IN (1, 3, 7, 8, 9)
			AND `unit_price` BETWEEN 50 AND 100
            AND `units_in_stock` > 0
	ORDER BY `suppliers`.`supplier_id` ASC;


/* EJERCICIO 2
Devuelve el nombre y apellidos y el id de los empleados con códigos entre el 3 y el 6,
además que hayan vendido a clientes que tengan códigos que comiencen con las letras de la A hasta la G.
Por último, en esta búsqueda queremos filtrar solo por aquellos envíos en que la fecha de pedido este comprendida entre el 22 y el 31 de Diciembre de cualquier año.*/

/*Se ha utilizado inner join para unir tres tablas, porque se necesitaban los datos de las tres. Se ha puesto en medio la tabla orders porque es la que tiene 
elementos en común con las otras dos. Después se han pasado condiciones con el where y se han agrupado com,o pide el ejercicio. */

SELECT `employees`.`first_name`, `employees`.`last_name`, `employees`.`employee_id`
	FROM `employees`
	INNER JOIN `orders` ON `employees`.`employee_id` = `orders`.`employee_id`
	INNER JOIN `customers` ON `customers`.`customer_id` = `orders`.`customer_id`
	WHERE `employees`.`employee_id` BETWEEN 3 AND 6
		AND `customers`.`customer_id` REGEXP '[A-G]\w*'
		AND MONTH(`orders`.`order_date`) = 12 
		AND DAY(`order_date`) BETWEEN 22 AND 31
	GROUP BY `employees`.`employee_id`;

/* EJERCICIO 3
Calcula el precio de venta de cada pedido una vez aplicado el descuento. Muestra el id del la orden, el id del producto, el nombre del producto,
el precio unitario, la cantidad, el descuento y el precio de venta después de haber aplicado el descuento. */

/*En este ejercicio no se tenía claro si se pedía el precio de cada pedido completo o de cada producto dentro de cada pedido, por lo que se ha intentado
reflejar las dos respuestas usando subquerys.
La primera subquery es de donde se han sacado la mayoría de datos. Se han utilizado todos los posibles de la tabla order_details y se ha calculado el 
precio de venta de cada producto dentro del mismo pedido.
De esta subquery se han referenciado la mayoría de resultados en la query principal.
En un pedido puede haber más de un producto, por lo que se ha creado una segunda subquery con otro inner join para sumar los productos que se han vendido 
en ese pedido. Después, se ha añadido ese resultado en la query principal. Este resultado (igual que el ID del pedido) sale repetido porque necesitamos ver
cada producto individual dentro de ese pedido.
*/

SELECT `precio_venta_prod`.`order_id`, `products`.`product_id`, `product_name`, `precio_venta_prod`.`unit_price`, `precio_venta_prod`.`quantity`,
		`precio_venta_prod`.`discount`, `precio_venta_prod`, `precio_venta_total`
	FROM `products`
	INNER JOIN (SELECT `order_details`.`order_id`, `order_details`.`product_id`, `order_details`.`unit_price`, `quantity`, `discount`,
						(`order_details`.`unit_price` * `quantity` * (1 - `discount`)) AS `precio_venta_prod`
				FROM `order_details`) AS `precio_venta_prod` ON `precio_venta_prod`.`product_id` = `products`.`product_id`
	INNER JOIN (SELECT `order_details`.`order_id`, SUM(`order_details`.`unit_price` * `quantity` * (1 - `discount`)) AS `precio_venta_total`
				FROM `order_details`
				GROUP BY `order_id`) AS `precio_venta_total` ON `precio_venta_total`.`order_id` = `precio_venta_prod`.`order_id`;


/* EJERCICIO 4
Usando una subconsulta, muestra los productos cuyos precios estén por encima del precio medio total de los productos de la BBDD. */

/*Primero se ha hecho una query para calcular la media de precios. Después, se ha usado como subquery para sacar la condición que se necesita para
la query principal*/

SELECT *
FROM `products`
WHERE `unit_price` > (SELECT AVG(`unit_price`) 
					FROM `products`);


/* EJERCICIO 5
¿Qué productos ha vendido cada empleado y cuál es la cantidad vendida de cada uno de ellos?*/ 

/*Se ha creado una subquery que obtenga los datos del ejercicio (ID empleado, ID producto y las cantidades que ha vendido de cada producto).
Para ello se han unido las dos tablas que tienen esos datos (orders y orders details).
Para sacar el nombre del empleado y del producto, se le han añadido dos inner joins para unirlo con las dos tablas que tienen esos datos
(employees y products). (Se ha puesto el inner join de la subquerie en medio de los dos para poder entrelazar las tablas porque éstas no tienen datos en común).*/ 

SELECT `employees`.`first_name`, `employees`.`last_name`, `products`.`product_name`, `cantidad_vendida`
	FROM `employees`
    INNER JOIN (SELECT `orders`.`employee_id`, `order_details`.`product_id`, SUM(`order_details`.`quantity`) AS `cantidad_vendida`
				FROM `orders` 
				INNER JOIN `order_details` ON `orders`.`order_id` = `order_details`.`order_id`
				GROUP BY `orders`.`employee_id`, `order_details`.`product_id`)AS `subconsulta` ON `employees`.`employee_id` = `subconsulta`.`employee_id`
	INNER JOIN `products` ON `subconsulta`.`product_id` = `products`.`product_id`;


/* EJERCICIO 6
Basándonos en la query anterior, ¿qué empleado es el que vende más productos? Soluciona este ejercicio con una subquery*/

/*Se ha decidido utilizar dos subqueries para poder obtener el nombre de la empleada y no solo el ID.
No se ha utilizado toda la consulta anterior, solo la subquery.
Partiendo de esa subquery, se ha hecho una query que obtenga el ID de la empleada con más ventas, sumando las cantidades vendidas, ordenándolo de forma
descendente y agrupándolo por el ID del empleado (al poner limit, solo nos sale el primer resultado).
Después, se ha hecho de esa query otra query, con la tabla employees, para sacar el nombre y apellido.*/

SELECT `employee_id`, `first_name`, `last_name`
FROM `employees`
WHERE `employee_id` = (SELECT `tabla_ventas`.`employee_id`
						FROM (SELECT `orders`.`employee_id`, `order_details`.`product_id`, SUM(`order_details`.`quantity`) AS `cantidad_vendida`
								FROM `orders`
								INNER JOIN `order_details` ON `orders`.`order_id` = `order_details`.`order_id`
								GROUP BY `orders`.`employee_id`, `order_details`.`product_id`) AS `tabla_ventas`
						GROUP BY `tabla_ventas`.`employee_id`
						ORDER BY SUM(`cantidad_vendida`) DESC 
						LIMIT 1);
 

/* EJERCICIO 6 BONUS
Soluciona este ejercicio con una CTE*/

/* Se ha utilizado la CTE para separar las 2 subconsultas y que no quedara una dentro de la otra. Primero se ha creado un WITH con lo primero que se quiere
resolver (los ID y cantidad vendida) y se le ha puesto el alias. Después se ha seguido con la query, haciendo una subquery sustituyendo los campos necesarios
por el alias, para conseguir el ID de empleado con mas ventas, y con ese dato se ha sacado el nombre y apellido. */

WITH `tabla_ventas` AS (SELECT `orders`.`employee_id`, `order_details`.`product_id`, SUM(`order_details`.`quantity`) AS `cantidad_vendida`
								FROM `orders`
								INNER JOIN `order_details` ON `orders`.`order_id` = `order_details`.`order_id`
								GROUP BY `orders`.`employee_id`, `order_details`.`product_id`)
                                
SELECT `employee_id`, `first_name`, `last_name`
FROM `employees`
WHERE `employee_id` = (SELECT `tabla_ventas`.`employee_id`
						FROM `tabla_ventas`
						GROUP BY `tabla_ventas`.`employee_id`
						ORDER BY SUM(`cantidad_vendida`) DESC 
						LIMIT 1);