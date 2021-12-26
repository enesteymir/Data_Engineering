/* 
Similar to SQL Functions, only we add BEGIN,END,pgSQL as language. Syntax;

 CREATE FUNCTION name (parameters) RETURNS var type AS $$
 BEGIN 
 ....statements...
 END;
 $$ LANGUAGE plpgsql ;
  
*/

-----------------------------------------------BASIC PLpgSQL FUNCTION----------------------------
CREATE FUNCTION max_price() 
RETURNS real AS $$

BEGIN
	RETURN MAX(unitprice)
	FROM products;
END;

$$ LANGUAGE plpgsql;


SELECT max_price();

-------------------------------------------FUNCTIONS WITH OUTPUT VARIABLES-----------
CREATE OR REPLACE FUNCTION sum_n_product (x int, y int, OUT sum int, OUT product int) AS $$

BEGIN
	sum := x + y;
	product := x * y;
	RETURN;
END;

$$ LANGUAGE plpgsql;

SELECT sum_n_product(5, 20);

----------------------------------------------RETURNING QUERY RESULT----------------

--Example : Return all products that sold greater than input parameter value. We use SETOF syntax as it will be used in subquery.

CREATE OR REPLACE FUNCTION sold_more_than(total_sales real)

RETURNS SETOF products AS $$ 

BEGIN
 RETURN QUERY SELECT * FROM products
 WHERE productid IN 
     (
      SELECT productid FROM
 	       (SELECT SUM(quantity*unitprice),productid
		    FROM order_details
	 	    GROUP BY productid
		    HAVING SUM(quantity*unitprice) > total_sales
		    ) as qualified_products
      );
       
 IF NOT FOUND THEN
 RAISE EXCEPTION 'Nn products had sales higher than %.', total_sales;
 END IF;
     
END;
$$ LANGUAGE plpgsql;


SELECT  sold_more_than(25000); -- Returns only the products
SELECT  (sold_more_than(25000)).*;  -- Returns all the columns of related products

-------------------------------------------WITH VARIABLES---------------------------------------------------

--Finding the products between 75% and 125% of the average priced item
CREATE OR REPLACE FUNCTION middle_priced()
RETURNS SETOF products AS $$

	DECLARE
		average_price real;
		bottom_price real;
		top_price real;
	BEGIN
		SELECT AVG(unitprice) INTO average_price
		FROM products;

		bottom_price := average_price * .75;
		top_price := average_price * 1.25;

		RETURN QUERY SELECT * FROM products
		WHERE unitprice between bottom_price AND top_price;
	END;
$$ LANGUAGE plpgsql;

------------------------------------------LOOPING THROUGH QUERY RESULTS-----------------------------------
CREATE FUNCTION reports_to(IN eid smallint, OUT employeeid smallint, OUT reportsto smallint) RETURNS SETOF record AS $$

WITH RECURSIVE reports_to(employeeid,reportsto) AS (
		SELECT employeeid,reportsto FROM employees
		WHERE employeeid = eid
		UNION ALL
		SELECT manager.employeeid,manager.reportsto
		FROM employees AS manager
		JOIN reports_to ON reports_to.reportsto = manager.employeeid
	)
	SELECT * FROM reports_to;

$$ LANGUAGE SQL;

------------------------------------------USING IF THEN STATEMENTS------------------------------------------

CREATE OR REPLACE FUNCTION time_of_year(date_to_check timestamp) RETURNS text AS $$

DECLARE
	month_of_year int := EXTRACT(MONTH FROM date_to_check);
BEGIN

	IF month_of_year >=3 AND month_of_year <=5 THEN
		RETURN 'Spring';
	ELSIF month_of_year >= 6 AND month_of_year <=8 THEN
		RETURN 'Summer';
	ELSIF month_of_year >= 9 AND month_of_year <=11 THEN
		RETURN 'Fall';
	ELSE
		RETURN 'Winter';
	END IF;
END;
$$ LANGUAGE plpgsql;

SELECT  time_of_year(orderdate),*
FROM orders;

---------------------------------------------RETURNING QUERY RESULT WITH LOOP--------------

CREATE OR REPLACE FUNCTION after_christmas_sale() RETURNS SETOF products AS $$
DECLARE
	product record;
BEGIN
	FOR product IN
		SELECT * FROM products
	LOOP
		IF product.categoryid IN (1,4,8) THEN
			product.unitprice = product.unitprice * .80;
		ELSIF product.categoryid IN (2,3,7) THEN
			product.unitprice = product.unitprice * .75;
		ELSE
			product.unitprice = product.unitprice * 1.10;
		END IF;
		RETURN NEXT product;
	END LOOP;

	RETURN;

END;
$$ LANGUAGE plpgsql;

SELECT * FROM after_christmas_sale();

-------------------------------------------LOOP AND WHILE------------------

--Ex 1 WITHOUT WHILE

CREATE OR REPLACE FUNCTION factorial(x float)
RETURNS float AS $$
DECLARE
	current_x float := x;
	running_multiplication float := 1;
BEGIN
	LOOP
		running_multiplication := running_multiplication * current_x;

		current_x := current_x - 1;
		EXIT WHEN current_x <= 0;
	END LOOP;

	RETURN running_multiplication;

END;
$$ LANGUAGE plpgsql;

SELECT factorial(13::float);

--Ex 2 WITH WHILE


CREATE OR REPLACE FUNCTION factorial(x float)
RETURNS float AS $$
DECLARE
	current_x float := x;
	running_multiplication float := 1;
BEGIN
	WHILE current_x > 0 
	LOOP
		running_multiplication := running_multiplication * current_x;

		current_x := current_x - 1;
	END LOOP;

	RETURN running_multiplication;

END;
$$ LANGUAGE plpgsql;

































