-- CTE : Common Table Expression

--Temporary table that will be used for another query later
WITH slowest_products AS 
(   
    SELECT productid,SUM(od.quantity)
	FROM products
	JOIN order_details AS od USING (productid)
	GROUP BY productID
	ORDER BY SUM(od.quantity) ASC
	LIMIT 2
)

--Now we use the table above for filtering
SELECT DISTINCT(companyname)
FROM customers
NATURAL JOIN orders
NATURAL JOIN order_details
WHERE productid IN (SELECT productid FROM  slowest_products)


-------------------------------USING RECURSION IN CTEs---------------------------
--Example 1
WITH RECURSIVE upto(t) AS (
	SELECT 1
	UNION ALL
	SELECT t+1 FROM upto
	WHERE t < 50
)
SELECT * FROM upto

--Example 2
WITH RECURSIVE downfrom(t) AS (
	SELECT 500
	UNION ALL
	SELECT t-2 FROM downfrom
	WHERE t > 2
)
SELECT * FROM downfrom

--Finding everyone that the CEO is responsible for EmployeeID=200
WITH RECURSIVE under_responsible(firstname,lastname,title, employeeid,reportsto,level) AS 
(
	SELECT firstname,lastname,title,employeeid,reportsto,0 FROM employees
	WHERE employeeid=200
	UNION ALL
	SELECT M.firstname,M.lastname,M.title,M.employeeid,M.reportsto,level+1
	FROM employees AS M
	JOIN under_responsible ON M.reportsto=under_responsible.employeeid
)
SELECT * FROM under_responsible


