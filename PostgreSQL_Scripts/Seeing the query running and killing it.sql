DROP TABLE IF EXISTS performance_test;

CREATE TABLE performance_test 
(
  id serial,
  location text
);

-- lets say you write false series and query must be killed
INSERT INTO performance_test (location)
SELECT 'Katmandu, Nepal' FROM generate_series(1,500000000);

-- See what is running, you will see the pid column, copy it
SELECT * FROM pg_stat_activity WHERE state = 'active';

-- First polite way, 
SELECT pg_cancel_backend(PID);

-- Second way, stop at all costs - can lead to full database restart
SELECT pg_terminate_backend(PID);
