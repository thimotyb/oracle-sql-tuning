--Connect as user sh in SQL Developer to run the statement
--Click on the EXPLAIN PLAN tool icon in the SQL Worksheet and verify the execution plan for UNION or UNION ALL operator

SELECT cust_last_name 
FROM customers
WHERE cust_city = 'Paris'
UNION
SELECT cust_last_name FROM customers
WHERE cust_credit_limit < 10000;

