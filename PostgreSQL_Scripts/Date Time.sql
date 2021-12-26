/*
You can specify precision of the seconds value (number of digits after decimal point)

-timestamp(3) : 1/8/2019 12:22:22:321
-time(4)      : 02:12:01.4321


You can allow time zones or not - default is no time zone if not specified

-timestamp with no time zone
-timestamp without time zone
-time with time zone
-time without time zone

*/

-- TO Learn the DateStyle OF this db;
SHOW DateStyle  

-- CHANGE the DateStyle MDY is Month Day Year, DMY is Day Month Year
SET DateStyle = 'ISO,DMY'

--Looking the Time Zones AND Abbreviations
SELECT * FROM pg_timezone_names;

SELECT * FROM  pg_timezone_abbrevs;

--Adding time column
ALTER TABLE test_time
ADD COLUMN endstamp TIMESTAMP WITH TIME ZONE;

ALTER TABLE test_time
ADD COLUMN endtime TIME WITH TIME ZONE;

--------------EXTRACTING DATE AND TIME------------------------------------------------
SELECT EXTRACT(YEAR FROM age(birthdate)),firstname, lastname
FROM employees;

SELECT date_part('day', shippeddate)
FROM orders;

SELECT EXTRACT(DECADE FROM age(birthdate)),firstname, lastname
FROM employees;

SELECT date_part('DECADE',age(birthdate)),firstname, lastname
FROM employees;

---------------CONVERTING--------------------

-- :: is the same as cast function
SELECT hiredate::TIMESTAMP
FROM employees;

-- this gives same output as above
SELECT CAST(hiredate AS TIMESTAMP)
FROM employees;

--ceil function is used for round the decimal to nearest integer, || is used for concatenate
SELECT (ceil(unitprice*quantity))::TEXT || ' dollars spent'
FROM order_details;

-----------------------DATE ARITHMETICS------------------------------------
-- subtracting intervals from date,time, timestamp
SELECT DATE '2018-10-20' - INTERVAL '2 months 5 days';

SELECT TIME '23:39:17' - INTERVAL '12 hours 7 minutes 3 seconds'

SELECT TIMESTAMP '2016-12-30' - INTERVAL '27 years 3 months 17 days 3 hours 37 minutes';

-- subtracting integer from date
SELECT DATE '2016-12-30' - INTEGER '300';

--subtracting 2 dates
SELECT DATE '2016-12-30' - DATE '2009-04-7';

-- subtracting 2 times and 2 timestamps
SELECT TIME '17:54:01' - TIME '03:23:45';

SELECT TIMESTAMP '2001-02-15 12:00:00' - TIMESTAMP '1655-08-30 21:33:05';

--Multiply and divide intervals
SELECT 5 * INTERVAL '7 hours 5 minutes';

SELECT INTERVAL '30 days 20 minutes' / 2;

SELECT age(TIMESTAMP '2025-10-03', TIMESTAMP '1999-10-03');
SELECT age (TIMESTAMP '1969-04-20');
