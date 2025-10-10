--Connect as user sh in SQL Developer to run the statement
--Click on the EXPLAIN PLAN tool icon in the SQL Worksheet and verify the execution plan and check whetherthe optimizer uses join methods

SELECT cust_state_province, sum(s.amount_sold) 
FROM sales s, customers c
WHERE s.cust_id = c.cust_id 
AND c.cust_year_of_birth= 1988 
GROUP BY cust_state_province;
