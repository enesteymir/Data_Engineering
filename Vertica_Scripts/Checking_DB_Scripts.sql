-- Check all tables in DB
SELECT * FROM tables;


-- Check all projections created for tables in DB
SELECT * FROM projections ;


-- Check tables' size in DB
SELECT anchor_table_schema,
anchor_table_name,
((SUM(USED_BYTES))/1024/1024/1024)  AS TABLE_SIZE_GB
FROM   v_monitor.column_storage
GROUP  BY anchor_table_schema,
anchor_table_name
order  by sum(used_bytes) desc;


-- Check DB size
SELECT GET_COMPLIANCE_STATUS();


-- List the functions
SELECT *
FROM v_catalog.user_functions
WHERE schema_name NOT LIKE 'v_%' ;


-- Show enabled roles and search paths, set path to schema for functions
SHOW search_path;
SHOW enabled roles;
SET SEARCH_PATH to schema_name;


-- Grant Functions
GRANT ALL ON LIBRARY schema_name.ApproximateLib to user_name;
GRANT EXECUTE ON TRANSFORM FUNCTION schema_name.APPROXIMATE_PERCENTILE() TO user_name;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA schema_name TO user_name;





