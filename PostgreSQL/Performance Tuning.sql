--PERFORMANCE TUNING

----------------------------------------------------EXPLAIN VE INDEX OLUSTURMA -----------------------------------------
/* Index Types

 1. B-Tree  => The most popular one and this is the default one, It works for <,>,<=,=,>= operators
 2. Hash    => It works for = operator only.
 3. GIN     => Useful for data types that have multiple values in a column such as Arrays, Range Types, JSONB, Hstore-key/value pairs
 4. Gist    => Useful when you have data that overlap with the value of that column- like geometry of full text search
 5. BRIN    => Best used for large datasets that have some natural orderin like series or zip codes. The more sequential the ordering the better
 6. SP-GIST => Useful for data that has a natural clustering to it but not balanced. Such as country phone numbers. Clustered around area code, next one changes like 0216 426 ..., 0216 215 ...

 If you want to specify the type of index, use the query below ;
 
 CREATE INDEX name
 ON table USING indextype (column)      
 
*/

-- Test Tablosu Olusturma 

DROP TABLE IF EXISTS performance_test;

CREATE TABLE performance_test (
  id serial,
  location text
);

INSERT INTO performance_test (location)
SELECT md5(random()::text) FROM generate_series(1,1000000); -- Say? büyütülerek performans k?yaslamalar? dah net görülebilir

-- notice that it does a sequential scan
EXPLAIN SELECT COUNT(*) FROM performance_test;

EXPLAIN SELECT * FROM performance_test
WHERE id = 200000;

-- After index, it uses Index Scan
CREATE INDEX idx_performance_test_id ON performance_test (id);

EXPLAIN SELECT * FROM performance_test
WHERE id = 200000;

-------------------------------------------------------ANALYSE ILE PERF ARTIRIMI --------------------------------------------

/* Ara ara Analyse kullanarak büyüyen ve degisen tablonun performansı artirilabilir */

ANALYSE performance_test


------------------------------------------------------- USING INDEXES ON MORE THAN ONE FIELD----------------------------------
ALTER TABLE performance_test
ADD COLUMN name text;

UPDATE performance_test
SET name = md5(location);

-- takes above 300ms after data cached
EXPLAIN ANALYZE SELECT *
FROM  performance_test
WHERE location LIKE 'df%' AND name LIKE 'cf%';

CREATE INDEX idx_peformance_test_location_name
ON performance_test(location,name);

-- takes 55 ms
EXPLAIN ANALYZE SELECT *
FROM  performance_test
WHERE location LIKE 'df%' AND name LIKE 'cf%';

-- this can't use index
EXPLAIN ANALYZE SELECT *
FROM  performance_test
WHERE  name LIKE 'cf%';

-- this can
EXPLAIN ANALYZE SELECT *
FROM  performance_test
WHERE location LIKE 'df%';

-------------------------------------------------------CONTROL INDEX FOR UPPER AND CREATE INDEX FOR THEM ----------------------
--Control the indexing for Upper
EXPLAIN select *
from production.product
WHERE UPPER(NAME) LIKE UPPER('Flat%');

-- create an expression scan, now it it better
CREATE INDEX idx_product_upper_name
ON production.product (UPPER(name));

------------------------------------------------------SPEEDING UP TEXT MATCHING ----------------------------------------------

/* Pattern Matching is slow on Regular Indexes (Where kosullar?nda text filtrelemesinde normal indexlemeler yavas cal?sir) */

CREATE EXTENSION pg_trgm;

-- Location sutununda GIN indexleme tipini kullanalim
CREATE INDEX trgm_idx_performance_test_location
ON performance_test USING gin (location gin_trgm_ops);

-- Name sutununda normal indexleme kullanal?m
CREATE INDEX idx_performance_test_name
ON performance_test (name);

-- terrible performance because of "name" column used in condition
EXPLAIN ANALYZE SELECT location
FROM  performance_test
WHERE name LIKE '%dfe%';

--only situation where pattern matching works
EXPLAIN ANALYZE SELECT location
FROM  performance_test
WHERE name LIKE 'dfe%';

-- much better performance because we used "location" column in where condition
EXPLAIN ANALYZE SELECT location
FROM  performance_test
WHERE location LIKE '%dfe%';

EXPLAIN ANALYZE SELECT location
FROM  performance_test
WHERE location LIKE 'dfe%';

------------------------------------------------------ HOW IS QUERY COST CALCULATED --------------------------------------

/*   Two Basic Cost
     1 - I/O Costs - Reading and Writing to disk
     2 - CPU Costs - Processing Cost
  
     The Total Cost = (Number Of Relation Pages * seq_page_cost)  +  (Number of Rows * cpu_tuple_cost)  +  (Number of Rows * cpu_operator_cost)
*/


SET max_parallel_workers_per_gather = 0;

EXPLAIN SELECT * FROM performance_test
WHERE location like 'ab%';

-- size of table
SELECT pg_relation_size('performance_test'),
  pg_size_pretty(pg_relation_size('performance_test'));


-- number of relation pages
SELECT relpages
FROM pg_class
WHERE relname='performance_test';


SELECT relpages, pg_relation_size('performance_test') / 8192 as TestingSize
FROM pg_class
WHERE relname='performance_test';

-- I/O cost per relationship page read
SHOW seq_page_cost;

-- total I/O cost
SELECT relpages * current_setting('seq_page_cost')::numeric
FROM pg_class
WHERE relname='performance_test';

-- number of rows
SELECT reltuples
FROM pg_class
WHERE relname='performance_test';

--CPU cost per row processed
SHOW cpu_tuple_cost;
SHOW cpu_operator_cost;

-- Total CPU Costs
SELECT reltuples * current_setting('cpu_tuple_cost')::numeric +
reltuples * current_setting('cpu_operator_cost')::numeric
FROM pg_class
WHERE relname='performance_test';

-- Total Costs for a table scan
SELECT relpages * current_setting('seq_page_cost')::numeric +
reltuples * current_setting('cpu_tuple_cost')::numeric +
reltuples * current_setting('cpu_operator_cost')::numeric
FROM pg_class
WHERE relname='performance_test';

SHOW parallel_setup_cost;
SHOW parallel_tuple_cost;

SET max_parallel_workers_per_gather = 4;
EXPLAIN (ANALYZE, VERBOSE) SELECT * FROM performance_test
WHERE location like 'ab%';



