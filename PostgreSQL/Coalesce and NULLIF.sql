/*
 COALESCE returns first non-null value in the list of fields ; 
 COALESCE(Field1,Field2,...)
*/

SELECT companyname,COALESCE(homepage,'Call to find') from suppliers;

/*
 NULLIF returns a null if two values are equal.
*/
UPDATE suppliers
SET homepage = ''
WHERE homepage IS NULL;

UPDATE customers
SET fax = ''
WHERE fax IS NULL;

--The query below, NULLIF checks that missing value of homepage field. if homepage value is ' ' then it gives NULL,after that, COALESCE sees it as NULL so that says 'Need to call'
SELECT companyname,phone,
COALESCE(NULLIF(homepage,''),'Need to call')  
FROM suppliers;
