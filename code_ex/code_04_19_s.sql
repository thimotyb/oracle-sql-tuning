--Connect as user sh in SQL Developer to run the statement
--Click on the EXPLAIN PLAN tool icon in the SQL Worksheet and verify the execution plan to check usage of INDEX and BETWEEN operator


SELECT cust_id, cust_first_name, cust_last_name, cust_state_province 
FROM customers
WHERE country_id between 52788 and 52790
AND cust_state_province like 'W%'; 
