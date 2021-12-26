-- Lets create audit table and insert changed information into this audit table when insert,delete or update happens.

CREATE TABLE order_details_audit (
	operation char(1) NOT NULL,
	userid	text NOT NULL,
	stamp	timestamp NOT NULL,
    orderid smallint NOT NULL,
    productid smallint NOT NULL,
    unitprice real NOT NULL,
    quantity smallint NOT NULL,
    discount real
)

/* TG_OP Data type text; a string of INSERT, UPDATE, DELETE, or TRUNCATE telling for which operation the trigger was fired. */
CREATE OR REPLACE FUNCTION audit_order_details() RETURNS trigger AS $$
BEGIN
	IF (TG_OP == 'DELETE') THEN
		INSERT INTO order_details_audit
		SELECT 'D',user,now(),o.* FROM old_table o;
	ELSIF (TG_OP == 'UPDATE') THEN
		INSERT INTO order_details_audit
		SELECT 'U',user,now(),n.* FROM new_table n;
	ELSIF (TG_OP == 'INSERT') THEN
		INSERT INTO order_details_audit
		SELECT 'U',user,now(),n.* FROM new_table n;
	END IF;
	RETURN NULL;  -- we are using in after trigger so don't need to return update

END;
$$ LANGUAGE plpgsql;

----------------------------FOR INSERT------------------------

DROP TRIGGER IF EXISTS audit_order_details_insert ON order_details;

CREATE TRIGGER audit_order_details_insert AFTER INSERT ON order_details
REFERENCING NEW TABLE AS new_table
FOR EACH STATEMENT EXECUTE FUNCTION audit_order_details();

----------------------------FOR UPDATE------------------------

DROP TRIGGER IF EXISTS audit_order_details_update ON order_details;

CREATE TRIGGER audit_order_details_update AFTER UPDATE ON order_details
REFERENCING NEW TABLE AS new_table
FOR EACH STATEMENT EXECUTE FUNCTION audit_order_details();

----------------------------FOR DELETE------------------------

DROP TRIGGER IF EXISTS audit_order_details_delete ON order_details;

CREATE TRIGGER audit_order_details_delete AFTER DELETE ON order_details
REFERENCING OLD TABLE AS old_table
FOR EACH STATEMENT EXECUTE FUNCTION audit_order_details();




INSERT INTO order_details
VALUES (10248, 3, 10, 5, 0);

SELECT * FROM order_details_audit;

update order_details
SET discount=0.20
WHERE orderid=10248 AND productid=3;

SELECT * FROM order_details_audit;

DELETE FROM order_details
WHERE orderid=10248 AND productid=3;

SELECT * FROM order_details_audit;



