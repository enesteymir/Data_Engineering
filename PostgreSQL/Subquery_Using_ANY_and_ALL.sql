
-- THE CUSTOMERS WITH ORDER DETAIL WITH MORE THAN 50 ITEMS IN A SINGLE PRODUCT

SELECT companyname
FROM customers
WHERE  customerid = ANY (SELECT customerid FROM orders
                         JOIN order_details ON orders.orderid=order_details.orderid
                         WHERE quantity > 50);

-- THE ALL SUPPLIERS THAT HAVE HAD AN ORDER WITH 1 ITEM
                        
SELECT companyname
FROM suppliers
WHERE  supplierid = ANY (SELECT products.supplierid FROM order_details
                        JOIN products ON products.productid=order_details.productid
                        WHERE quantity = 1);

-- WHICH HAD ORDER AMOUNTS THAT WHERE HIGHER THA THE AVERAGE OF ALL THE PRODUCTS                      
                       
SELECT productname
FROM products
JOIN order_details ON products.productid=order_details.productid
WHERE  order_details.unitprice*quantity > ALL
	(SELECT AVG(order_details.unitprice*quantity)
             FROM order_details
             GROUP BY productid);

-- FIND ALL DISTINCT CUSTOMERS, THAT ORDERED MORE IN ONE ITEM THAN THE AVERAGE ORDER AMOUNT PER ITEM OF ALL CUSTOMERS          
            
 SELECT DISTINCT companyname
 FROM customers
 JOIN orders ON orders.customerid=customers.customerid
 JOIN order_details ON orders.orderid=order_details.orderid
 WHERE  order_details.unitprice*quantity > ALL
 	(SELECT AVG(order_details.unitprice*quantity)
              FROM order_details
             JOIN orders ON orders.orderid=order_details.orderid
             GROUP BY orders.customerid);
