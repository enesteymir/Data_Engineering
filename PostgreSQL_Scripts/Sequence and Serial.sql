/*  Sequence is used for generating unique numeric identifiers   */

----------------------------------------CREATING SEQUENCE--------------------------------------
CREATE SEQUENCE test_sequence;

-- When you run it it increase 1
SELECT nextval('test_sequence');

--This gives the current value
SELECT currval('test_sequence');

--The most recent value
SELECT lastval();

-- set value but next value will increment
SELECT setval('test_sequence',14);
SELECT nextval('test_sequence');

-- set value and next value will be what you set
SELECT setval('test_sequence',25,false);
SELECT nextval('test_sequence');

--Creating sequence that increase by 5 
REATE SEQUENCE IF NOT EXISTS test_sequence2 INCREMENT 5;
SELECT nextval('test_sequence2');

--Setting min,max value and also start value
CREATE SEQUENCE IF NOT EXISTS test_sequence_3
INCREMENT 50 MINVALUE 350 MAXVALUE 5000 START WITH 550;
SELECT nextval('test_sequence_3');

----------------------------------------ADDING SEQUENCE TO A TABLE----------------------------------------------------------
SELECT max(employeeID) FROM employee

--Attaching sequence to a column(field), it starts with 10 because 9 is the last ID one as can be seen below
CREATE SEQUENCE IF NOT EXISTS employees_employeeid_seq
START WITH 10 OWNED BY employees.employeeid;

--This insert will fail, because employeID will give error
INSERT INTO employees
(lastname,firstname,title,reportsto)
VALUES ('Smith','Bob', 'Assistant', 2);

--must alter the default value of employeID
ALTER TABLE employees
ALTER COLUMN employeeid SET DEFAULT nextval('employees_employeeid_seq');

--Now Insert will work!
INSERT INTO employees
(lastname,firstname,title,reportsto)
VALUES ('Smith','Bob', 'Assistant', 2);

----------------------------------------ALTER AND  DELETE SEQUENCE---------------------------
--Changıng the name of sequence
ALTER SEQUENCE test_sequence RENAME TO test_sequence_new

--changıng starts value of sequence
ALTER SEQUENCE test_sequence RESTART WITH 1541
SELECT nextval('test_sequence')

--Dropping the sequence
DROP SEQUENCE test_sequence

----------------------------------------USING SERIAL DATATYPES------------------
/*
SMALLSERIAL : small int that increments automatically
SERIAL      : int that increments automatically
BIGSERIAL   : bigint that increments automatically
*/

CREATE TABLE pets (
petid SERIAL,
name varchar(255)
);

INSERT INTO pets (name) VALUES ('Fluffy') RETURNING petid;



