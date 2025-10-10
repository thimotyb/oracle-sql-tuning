--Connect as user sh in SQL Developer to run the statement
--Click on the EXPLAIN PLAN tool icon in the SQL Worksheet and verify the execution plan and check whetherthe optimizer uses join methods

SELECT channel_id,
SUM(amount_sold)
FROM sales
GROUP BY channel_id;
