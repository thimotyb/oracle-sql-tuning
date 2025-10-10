--Connect as user sh in SQL Developer to run the statement
--Click on the EXPLAIN PLAN tool icon in the SQL Worksheet and verify the execution plan

SELECT sum(s.quantity_sold) 
FROM sales s, products p
WHERE s.prod_id = p.prod_id
AND p.prod_subcategory = 'CD-ROM';
