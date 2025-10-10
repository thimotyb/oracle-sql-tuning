--Connect as user sh in SQL Developer to run the statement
--Click on the EXPLAIN PLAN tool icon in the SQL Worksheet and verify the execution plan and check whetherthe optimizer chooses the full table scan


SELECT prod_id, time_id, promo_id, channel_id, unit_cost
FROM costs
WHERE prod_id = 120; 
