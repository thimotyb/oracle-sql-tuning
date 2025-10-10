--Connect as user sh in SQL Developer to run the statement
  
DROP INDEX cust_maritial_status_idx;

CREATE INDEX cust_maritial_status_idx
ON customers(cust_marital_status);

 --Click on the EXPLAIN PLAN tool icon in the SQL Worksheet and verify the execution plan for index usage

SELECT  count(*) FROM customers;
