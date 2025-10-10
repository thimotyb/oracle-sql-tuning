--Connect as user sh in SQL Developer to run the statement
--Click on the EXPLAIN PLAN tool icon in the SQL Worksheet and verify the execution plan for index usage. 

SELECT cust_first_name, cust_last_name FROM customers 
WHERE cust_id = 1030;
