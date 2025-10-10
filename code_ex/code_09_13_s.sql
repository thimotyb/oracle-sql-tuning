--Use the oe schema to execute the SQL statement in SQL Developer

CREATE INDEX INV_QTY_INDEX ON INVENTORIES(quantity_on_hand)
/

--Click on the EXPLAIN PLAN tool icon in the SQL Worksheet and verify the execution plan 

SELECT MIN(quantity_on_hand) 
FROM INVENTORIES 
WHERE quantity_on_hand < 500;
