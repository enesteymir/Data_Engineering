/*
DATABASE Transactions;
A group of database statements that are performed together.

There are 4 properties;
A- Atomicity  : All the operations in transaction work or none of them work. Everything is done as a single unit.
C- Consistency: All transaction change the database state properly
I- Isolation  : Transactions won't interfere with each other. For ex, While you are reading a table, an update won't happen. The read occur before or after update.
D- Durability : The canges or results won't be lost if there is a system failure.
*/

----------------------------------------------------SIMPLE TRANSACTION CONTROL-------------------------------------------
/* In SQL Standard Syntax
  
  START TRANSACTION;
  Statement 1
  Statement 2
  ...
  
  COMMIT;
  
 Alternative Syntax (In PostgreSQL); 

 START TRANSACTION;
  Statement 1
  Statement 2
  ...
  
  COMMIT;

*/

--Lets update the reordder level and find the count of items that need reordering 

BEGIN TRANSACTION; --START TRANSACTION
	UPDATE products
	SET reorderlevel = reorderlevel - 5;

	SELECT COUNT(*)
	FROM products
	WHERE unitsinstock + unitsonorder < reorderlevel;

END TRANSACTION; --COMMIT

------------------------------------------------------------ROLLBACKS & SAVEPOINTS-------------------------------

/*
 Rollback aborts all changes in current transaction. Usefull more in PL/pgSQL programming where you have if/then statements.
 Savepoint allows you to do a partial rollback. So you can rollback to savepoint
*/

-- Simple Example
START TRANSACTION;

UPDATE orders
SET orderdate = orderdate + INTERVAL '1 YEAR';

ROLLBACK;

-- Lets start a new transaction, insert a new employee, create a savepoint, update hiredate and rollback to savepoint
START TRANSACTION;

INSERT INTO employees (employeeid,lastname,firstname,title,birthdate,hiredate)
VALUES (501,'Sue','Jones','Operations Assistant','1999-05-23','2017-06-13');

SAVEPOINT inserted_employee; -- We saved until this statement

UPDATE employees
SET birthdate='2025-07-11';

ROLLBACK TO inserted_employee; --We want to return to savepoint because we did false thing and change all the employees' birthdates

UPDATE employees
SET birthdate='1998-05-23'
WHERE employeeid=501;  

COMMIT;

------------------------------------------------SQL TRANSACTION ISOLATION-----------------------------------------------------------

/* 
There are 3 phenomena which are prohibited at different isolation levels
1 - Dirty Reads  : While another transaction running, you read it
2 - Nonrepeatable Reads : For ex, reading sales totals in several places in a single transaction and data is changed between reads.
3 - Phantom Reads : Occurs when in the course of a transaction, new rows are added or removed by another transaction to the records being read.

Isolation Levels ;
					Dirty Read    NonRepeatable Read     Phantom
Read uncommitted	Yes					Yes					Yes  (Lowest Isolation Level)
Read committed	    No					Yes					Yes
Repeatable read	    No					No					Yes
Snapshot	        No					No					No
Serializable	    No					No					No




**/





















