/*
It acts like a stored query that you give a name
Once you created, you can use SELECT to pull information from like a regular table.
Used to keep from having to type in complex queries,
You can grant permissions by taking certaion fields from base tables.

You can update,delete or insert into a view if ;
-Only one table is referenced in FROM
-Can't have GROUP BY, HAVING, LIMIT, DISTINCT, UNION,INTERSECT,EXCEPT in query
-Can't any window functions,set returning function, or any aggregate functions like SUM,COUNT,AVG,MIN,MAX
*/
-------------------------------------------CREATE VIEW---------------------
CREATE VIEW customer_order_details AS
SELECT companyname,
Orders.customerid,
employeeid,
orderdate,
shippeddate,
freight,
shipname,
shipcity,
shippostalcode,
shipcountry,order_details.*
FROM customers
JOIN orders on customers.customerid=orders.customerid
JOIN order_details on order_details.orderid=orders.orderid;

SELECT *
FROM customer_order_details
WHERE customerid='TOMSP';

-----------------------------------------MODIFY VIEW----------------
--We add contactname field
CREATE OR REPLACE VIEW customer_order_details AS
SELECT companyname,
Orders.customerid,
employeeid,
orderdate,
shippeddate,
freight,
shipname,
shipcity,
shippostalcode,
shipcountry,order_details.*
contactname 
FROM customers
JOIN orders on customers.customerid=orders.customerid
JOIN order_details on order_details.orderid=orders.orderid;

--Changing the name OF the VIEW
ALTER VIEW customer_order_details RENAME TO customer_order_detailed;

--------------------------------------CREATING UPDATABLE VIEW EXAMPLE------------------
--The query must have rules that mentioned above
CREATE VIEW north_america_customers AS
SELECT *
FROM customers
WHERE country in ('USA','Canada','Mexico');

INSERT INTO north_america_customers
(customerid,companyname,contactname,contacttitle,address,city,region,postalcode,country,phone,fax)
VALUES ('CFDCM','Catfish Dot Com','Will Bunker','President','Old Country Road','Lake Village','AR','71653','USA','555-555-5555',null);

UPDATE north_america_customers SET fax='555-333-4141' WHERE customerid='CFDCM';

DELETE FROM north_america_customers WHERE customerid='CFDCM';

-----------------------------------------VIEW WITH CHECK OPTION--------------------------
--Change the norht_america_custmers view to check that the country is correct and test so that user can't insert into unvalid value.
CREATE OR REPLACE VIEW north_america_customers  AS
SELECT *
FROM customers
WHERE country in ('USA','Canada','Mexico')
WITH LOCAL CHECK OPTION;

--------------------------------------------DROP VIEW---------------------------------------
DROP VIEW IF EXISTS north_america_customers













