--------------------------------CREATING DB--------------------

CREATE DATABASE northwind2;

createdb fiddlesticks


CREATE DATABASE mydb5;

createdb mydb5_bak

----------------------INSTANCE LEVEL PERMISSIONs-------------

CREATE ROLE accounting NOCREATEDB NOLOGIN NOSUPERUSER;
CREATE ROLE hr NOCREATEDB NOLOGIN NOSUPERUSER;


CREATE ROLE suzy NOCREATEDB LOGIN NOSUPERUSER PASSWORD 'pass123';
CREATE USER bobby NOCREATEDB LOGIN NOSUPERUSER PASSWORD 'pass123';


REVOKE ALL ON DATABASE northwind FROM public; -- Revoke all permissions

GRANT  accounting TO suzy;
GRANT  hr TO bobby;

------------------------DATABASE LEVEL PERMISSIONs--------------

GRANT CONNECT ON DATABASE northwind TO accounting;
GRANT CONNECT ON DATABASE northwind TO hr;

 --still can't create schema
CREATE SCHEMA suzy;

--allow accounting to create schemas
GRANT CREATE ON DATABASE northwind TO accounting;

--now suzy can create schema
CREATE SCHEMA suzy;

GRANT CONNECT ON DATABASE northwind TO sales;
GRANT CREATE ON DATABASE northwind TO sales;

------------------------------SCHEMA LEVEL PERMISSONS------------

--suzy can create a table in public schema even though no explicit permissions
create table can_i (id int);

--We revoke all permissions on schema
REVOKE ALL ON SCHEMA public FROM public;
DROP TABLE can_i;

GRANT CREATE ON SCHEMA public TO accounting;
GRANT USAGE ON SCHEMA public TO accounting;  
GRANT USAGE ON SCHEMA public TO hr;

--------------------------------TABLE LEVEL PERMISSIONS------------------

GRANT SELECT ON ALL TABLES IN SCHEMA public TO accounting;

GRANT INSERT ON TABLE employees TO hr;
GRANT SELECT ON TABLE employees TO hr;
GRANT UPDATE ON TABLE employees TO hr;

GRANT SELECT ON TABLE customers TO sales;


----------------------------------COLUMN LEVEL PERMISSIONS------------------

--First we try to restrict
GRANT SELECT (employeeid, lastname, firstname, title, titleofcourtesy, hiredate, country, extension, photo, photopath)
ON employees
TO accounting;

--login in as suzy and try
SELECT * FROM employees;

--She sees everthing, must revoke select on all tables
REVOKE SELECT ON ALL TABLES
IN SCHEMA public
FROM accounting;

--then apply permissions
GRANT SELECT (employeeid, lastname, firstname, title, titleofcourtesy, hiredate, country, extension, photo, photopath)
ON employees
TO accounting;

--login in as suzy and try
SELECT * FROM employees;

--must use column names
SELECT firstname,lastname,hiredate FROM employees;

-----------------------------------------------ROW LEVEL PERMISSIONS----------------------



