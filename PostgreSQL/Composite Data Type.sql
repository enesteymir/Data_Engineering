/* Basically, it is a list of field names and their data types */

CREATE TYPE fulladdress AS (
	street_address 	varchar(50),
	street_address2 varchar(50),
	city			varchar(50),
	state_region	varchar(50),
	country			varchar(50),
	postalcode		varchar(15)
);

-- We use new data type in adress column
CREATE TABLE friends (
	first_name varchar(100),
	last_name varchar(100),
	address	fulladdress
);


--Deleting composite data type
DROP TYPE fulladdress CASCADE;


