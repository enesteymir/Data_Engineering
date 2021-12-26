/* Window functions operate on a set of rows and return a single value for each row from the underlying query. */

-- BASIC SYNTAX

SELECT *. 
FUNCTION() OVER (PARTITION BY field_name)
FROM ...

--AN EXAMPLE

SELECT categoryname,
productname,
unitprice,
AVG(unitprice) OVER (PARTITION BY categoryname)
FROM products
JOIN categories ON categories.categoryid=products.categoryid

--AN EXAMPLE WITH SUBQUERY

SELECT companyname,
orderid,
amount ,
average_order FROM

   (SELECT companyname, orderid, amount ,AVG(amount) OVER (PARTITION BY companyname) AS average_order
    FROM
		(SELECT companyname,orders.orderid,SUM(unitprice*quantity) AS amount
		 FROM customers
		 JOIN orders ON orders.customerid=customers.customerid
		 JOIN order_details ON orders.orderid=order_details.orderid
	     GROUP BY companyname,orders.orderid) as order_amounts) as order_averages
	     
WHERE amount > 5 * average_order
ORDER BY companyname


--RANK() WITH PARTITION
SELECT * FROM
(SELECT orders.orderid,
productid,
unitprice,
quantity,
RANK() OVER (PARTITION BY order_details.orderid ORDER BY (quantity*unitprice) DESC) AS rank_amount
FROM orders
NATURAL JOIN order_details) as ranked
WHERE rank_amount <=2;