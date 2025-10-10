--Connect as user sh in SQL Developer to run the statement


describe customers
/

--Click on the EXPLAIN PLAN tool icon in the SQL Worksheet and verify the execution plan for index usage.

SELECT cust_street_address 
FROM customers 
WHERE cust_postal_code =  68054;
