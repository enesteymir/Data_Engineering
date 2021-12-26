--------------------------------------BASIC FUNCTION SYNTAX-------------------------------------

/* if you want to define a SQL function that performs actions but has no useful value to return, you can define it as returning void*/

CREATE  OR REPLACE FUNCTION fix_homepage() 
RETURNS void AS $$
	UPDATE suppliers
	SET homepage='N/A'
	WHERE homepage IS NULL;
$$ LANGUAGE SQL;

SELECT fix_homepage();

----------------------------------FUNCTION THAT RETURNS A SINGLE VALUE-----------------------------

/* The double precision type typically has a range of around 1E-307 to 1E+308 with a precision of at least 15 digits. Values that are too large or too small will cause an error.
   Rounding might take place if the precision of an input number is too high. */


CREATE OR REPLACE FUNCTION biggest_order()
RETURNS double precision AS $$

	SELECT MAX(amount)
	FROM
	(SELECT SUM(unitprice*quantity) as amount,orderid
	FROM order_details
	GROUP BY orderid) as totals;

$$ LANGUAGE SQL;

SELECT biggest_order();

------------------------------------FUNCTIONS WITH PARAMETERS----------------------------------

/*
There are two ways to reference Parameters;
1. By name : param1, param2...
2. By position : $1, $2,..  (In older PostgreSQL version, By position is only way to do this.)

If you named the parameter the same as column names the function might get confused. 

*/

-- In this example, parameter is different name, cid
CREATE OR REPLACE FUNCTION customer_largest_order(cid bpchar)
RETURNS double precision AS $$
	SELECT MAX(order_total) FROM
	(SELECT SUM(quantity*unitprice) as order_total,orderid
	FROM order_details
	NATURAL JOIN orders
	WHERE customerid=cid
	GROUP BY orderid) as order_total;
$$ LANGUAGE SQL;

SELECT customer_largest_order('ANATR');



-- In this example, parameter is same name as column, so we use $1 notation.$1 means that it is the first parameter.
CREATE OR REPLACE FUNCTION most_ordered_product(customerid bpchar) RETURNS varchar(40) AS $$
	SELECT productname
	FROM products
	WHERE productid IN
	(SELECT productid FROM
	(SELECT SUM(quantity) as total_ordered, productid
	FROM order_details
	NATURAL JOIN orders
	WHERE customerid= $1  
	GROUP BY productid
	ORDER BY total_ordered DESC
	LIMIT 1) as ordered_products);
$$ LANGUAGE SQL;

SELECT most_ordered_product('CACTU');

---------------------------------------------FUNCTIONS WITH COMPOSITE PARAMETERS---------------------------------------------------
--Example 1, lets build a function that it takes two parameters; product and increase percent. Then it gives you the new price
CREATE OR REPLACE FUNCTION new_price(products, increase_percent numeric)
RETURNS double precision AS $$
	SELECT $1.unitprice * increase_percent/100
$$ LANGUAGE SQL

SELECT productname,unitprice,new_price(products.*,110)
FROM products;


--Example 2
CREATE OR REPLACE FUNCTION full_name(employees) 
RETURNS varchar(62) AS $$
	SELECT $1.title || ' ' || $1.firstname || ' ' || $1.lastname
$$ LANGUAGE SQL;

SELECT full_name(employees.*),city,country
FROM employees;

----------------------------------------------FUNCTIONS THAT RETURN A COMPOSITE-------------------------------------------
--Example 1
CREATE OR REPLACE FUNCTION newest_hire()
RETURNS employees AS $$
	SELECT *
	FROM employees
	ORDER BY hiredate DESC
	LIMIT 1;
$$ LANGUAGE SQL;

SELECT newest_hire(); --This gives in a single cell of all detail
SELECT (newest_hire()).lastname; 
SELECT lastname(newest_hire());
SELECT (newest_hire()).*;  -- This gives all the column seperately

--Example 2
CREATE OR REPLACE FUNCTION highest_inventory()
RETURNS products AS $$

	SELECT * FROM products
	ORDER BY (unitprice*unitsinstock) DESC
	LIMIT 1;

$$ LANGUAGE SQL;

SELECT (highest_inventory()).productname;
SELECT productname(highest_inventory());

----------------------------------------------FUNCTIONS WITH OUTPUT PARAMETERS----------------------------------------
CREATE OR REPLACE FUNCTION sum_n_product (x int, y int, OUT sum int, OUT product int) AS $$
	SELECT x + y, x * y
$$ LANGUAGE SQL;

SELECT sum_n_product(5, 20);
SELECT (sum_n_product(5, 20)).*;

--------------------------------------------FUNCTIONS WITH DEFAULT VALUES----------------------------------------
CREATE OR REPLACE FUNCTION new_price(products, increase_percent numeric DEFAULT 105)
RETURNS double precision AS $$
	SELECT $1.unitprice * increase_percent/100
$$ LANGUAGE SQL;

SELECT productname,unitprice,new_price(products) -- In here we didn't use second parameter so it uses default one
FROM products;

------------------------------------------WE CAN USE FUNCTIONS AS A TABLE SOURCE-----------------------------------
SELECT firstname,lastname,hiredate
FROM newest_hire();

---------------------------------------------FUNCTION THAT RETURNS MORE THAN ONE ROW------------------------------

/* When returning SETOF record the output columns are not typed and not named. Thus this form can't be used directly in a FROM clause.*/

--Example : Return all products that sold greater than input parameter value. We use SETOF syntax as it will be used in subquery.

CREATE OR REPLACE FUNCTION sold_more_than(total_sales real)
RETURNS SETOF products AS $$ 
 SELECT * FROM products
 WHERE productid IN (
	 SELECT productid FROM
 	 (	SELECT SUM(quantity*unitprice),productid
		 FROM order_details
	 	 GROUP BY productid
		 HAVING SUM(quantity*unitprice) > total_sales) as qualified_products
     )
$$ LANGUAGE SQL;


SELECT productname, productid, supplierid
FROM sold_more_than(25000);

--Example : Function that return all employees next birthday,first,last name and hiredate. We use TABLE syntax as it is used in directly FROM clause.

CREATE OR REPLACE FUNCTION next_birthday()
RETURNS TABLE (birthday date, firstname varchar(18), lastname varchar(28),hiredate date) AS $$
 SELECT (birthdate* INTERVAL '1 YEAR' * (EXTRACT(YEAR(FROM age(birthdate))+1))::date,
 firstname,lastname,hiredate
 FROM employees
$$ LANGUAGE SQL 

---------------------------------------------FUNCTION THAT DO NOT RETURN ANYTHING------------------------------------------

--Example : Creating a procedure that takes the supplierID and amount and increases all the unit prices in products table for that supplier

CREATE OR REPLACE PROCEDURE change_supplier_prices(supplierid smallint, amount real) AS $$

	UPDATE products
	SET unitprice = unitprice + amount
	WHERE supplierid = $1

$$ LANGUAGE;

CALL change_supplier_prices(20::smallint, 0.50);



