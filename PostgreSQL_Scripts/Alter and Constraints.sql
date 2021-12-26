----------------------------------------- ALTER---------------------------------
---CHANGE TABLE'S COLUMN
ALTER TABLE subscribers
RENAME firstname TO first_name;

--CHANGE TABLE ITSELF
ALTER TABLE subscribers
RENAME TO email_subscribers;

--ADD COLUMN
ALTER TABLE email_subscribers
ADD COLUMN last_visit_date timestamp;

--DROP COLUMN
ALTER TABLE email_subscribers
DROP COLUMN last_visit_date;

---CHANGING DATA TYPE OF A COLUMN
ALTER TABLE email_subscribers
ALTER COLUMN email SET DATA TYPE varchar(225);

--DROP TABLE
DROP TABLE email_subscribes

-------------------------------------------CONSTRAINTS-------------------------------
--NOT NULL
CREATE TABLE IF NOT EXISTS practices (
practiceid integer NOT NULL,
practice_field varchar(50) NOT NULL
);

ALTER TABLE products
ALTER COLUMN unitprice SET NOT NULL;

ALTER TABLE employees
ALTER COLUMN lastname SET NOT NULL;

--UNIQUE
CREATE TABLE pets (
	petid integer UNIQUE,
    name varchar(25) NOT NULL
)

ALTER TABLE tablename
ADD CONSTRAINT constraintname UNIQUE(columnname);

ALTER TABLE shippers
ADD CONSTRAINT shippers_companyname UNIQUE(companyname);

--PRIMARY KEY CONSTRAINT
CREATE TABLE pets (
	petid integer PRIMARY KEY,
name varchar(25) NOT NULL
);

ALTER TABLE practices
DROP CONSTRAINT practices_pkey;

ALTER TABLE practices
ADD PRIMARY KEY (practiceid);

--FOREIGN KEY
CREATE TABLE pets (
	petid integer PRIMARY KEY,
	name varchar(25) NOT NULL,
	customerid char(5) NOT NULL,
	FOREIGN KEY (customerid) REFERENCES customers(customerid)
)

ALTER TABLE pets
DROP CONSTRAINT pets_customerid_fkey;

ALTER TABLE pets
ADD CONSTRAINT pets_customerid_fkey
FOREIGN KEY (customerid) REFERENCES customers(customerid);

--CHECK CONSTRAINT
CREATE TABLE pets (
	petid integer PRIMARY KEY,
	name varchar(25) NOT NULL,
	customerid char(5) NOT NULL,
	weight integer CONSTRAINT pets_weight CHECK (weight > 0 AND weight < 200),
	FOREIGN KEY (customerid) REFERENCES customers(customerid)
);

ALTER TABLE orders
ADD CONSTRAINT orders_freight CHECK (freight > 0);

--DEFAULT CONSTRAINT
CREATE TABLE pets (
	petid integer PRIMARY KEY,
	name varchar(25) NOT NULL,
	customerid char(5) NOT NULL,
	weight integer DEFAULT 5 CONSTRAINT pets_weight CHECK (weight > 0 AND weight < 200),
	FOREIGN KEY (customerid) REFERENCES customers(customerid)
);

ALTER TABLE orders
ALTER COLUMN shipvia SET DEFAULT 1;


