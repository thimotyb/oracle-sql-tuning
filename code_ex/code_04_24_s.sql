--Connect as user sh in SQL Developer to run the statement
--Click on the EXPLAIN PLAN tool icon in the SQL Worksheet and verify the execution plan to check usage of INDEX.


SELECT cust_first_name, cust_last_name
FROM customers
WHERE cust_last_name like '%ing';
