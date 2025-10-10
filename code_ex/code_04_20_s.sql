--Connect as user sh in SQL Developer to run the statement
--Click on the EXPLAIN PLAN tool icon in the SQL Worksheet and verify the execution plan to check usage of INDEX.

SELECT /*+ index(s sales_pk) */ sum(amount_sold)
FROM sales s
WHERE prod_id BETWEEN 130 AND 150
AND cust_id BETWEEN 10000 AND 10100;
