--Connect as user sh in SQL Developer to run the statement
--Click on the EXPLAIN PLAN tool icon in the SQL Worksheet and verify the execution plan and check whether the optimizer uses bitmap index


SELECT s.amount_sold,p.prod_name,ch.channel_desc
FROM sales s, products p, channels ch, customers c
WHERE s.prod_id=p.prod_id
AND s.channel_id=ch.channel_id
AND s.cust_id=c.cust_id
AND ch.channel_id in (3, 4)
AND c.cust_city='Asten'
AND p.prod_id>100;
