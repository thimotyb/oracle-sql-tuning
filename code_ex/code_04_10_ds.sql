--Connect as user sh in SQL Developer to run the statement
--Click on the EXPLAIN PLAN tool icon in the SQL Worksheet and verify the execution plan to check usage of sort operations.

SELECT cust_first_name, cust_last_name, cust_city
    FROM customers
    WHERE cust_id < 200
    ORDER BY cust_id;
