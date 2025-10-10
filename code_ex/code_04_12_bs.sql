--Connect as user sh in SQL Developer to run the statement
--Click on the EXPLAIN PLAN tool icon in the SQL Worksheet and verify the execution plan to check usage of sort operations.

SELECT max(cust_credit_limit+1000)
    FROM customers;
