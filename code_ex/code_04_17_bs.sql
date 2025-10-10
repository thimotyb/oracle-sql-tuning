--Connect as user sh in SQL Developer to run the statement
--Click on the EXPLAIN PLAN tool icon in the SQL Worksheet and verify the execution plan to check usage of INDEX and HAVING operator


SELECT cust_city, avg(cust_credit_limit)
    FROM customers
    WHERE cust_city = 'Paris'
    GROUP BY cust_city;
