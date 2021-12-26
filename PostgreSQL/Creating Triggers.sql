/*
  Two variables that helps;
  For INSERT/UPDATE Triggers - NEW - holds the new database row
  For UPDATE/DELETE Triggers - OLD - holds the old database row
 */



-- One simple task that triggers are used for is to update timestamps every time a record is changed. Lets build one for employee database  

----------------------------------------------------------CREATING FUNCTION-----------------------------
ALTER TABLE employees
ADD COLUMN last_updated timestamp;

CREATE OR REPLACE FUNCTION employees_timestamp() RETURNS trigger AS $$
BEGIN

	NEW.last_updated := now();
	RETURN NEW;

END;
$$ LANGUAGE plpgsql;

------------------------------------------------------------CREATING TRIGGER-------------------------------------------- 
DROP TRIGGER IF EXISTS employees_timestamp ON employees;

CREATE TRIGGER employees_timestamp BEFORE INSERT OR UPDATE ON employees
	FOR EACH ROW EXECUTE FUNCTION employees_timestamp();

SELECT last_updated,*FROM EMPLOYEES
WHERE employeeid=1;

--Lets change something on this record
UPDATE employees
SET address = '27 West Bird Lane'
WHERE employeeid=1;

--So you will see that last updated time is changed for this record
SELECT last_updated FROM EMPLOYEES
WHERE employeeid=1;

------------------------------------------------------------------------Second Example--------------------------
-- Lets add a last_updated column to products table and create function and trigger that updates the field every time there is a change
ALTER TABLE products
ADD COLUMN last_updated timestamp;

CREATE OR REPLACE FUNCTION products_timestamp() RETURNS trigger AS $$
BEGIN

	NEW.last_updated := now();
	RETURN NEW;

END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS products_timestamp ON products;

CREATE TRIGGER products_timestamp BEFORE INSERT OR UPDATE ON products
	FOR EACH ROW EXECUTE FUNCTION products_timestamp();

SELECT last_updated,* FROM products
WHERE productid=2;

UPDATE products
SET unitprice=19.05
WHERE productid=2;

SELECT last_updated,* FROM products
WHERE productid=2;
