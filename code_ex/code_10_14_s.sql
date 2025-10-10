-- Use the oe schema to execute the SQL statement in SQL Developer

BEGIN
  DBMS_STATS.gather_table_STATS(OWNNAME =>'OE', TABNAME=>'INVENTORIES', 
  METHOD_OPT => 'FOR COLUMNS SIZE 10 quantity_on_hand');
END;
/
SELECT column_name, num_distinct, num_buckets, histogram 
  FROM USER_TAB_COL_STATISTICS
 WHERE table_name = 'INVENTORIES' AND column_name = 'QUANTITY_ON_HAND';
/
SELECT endpoint_number, endpoint_value 
FROM USER_HISTOGRAMS
WHERE table_name = 'INVENTORIES' and column_name = 'QUANTITY_ON_HAND'
ORDER BY endpoint_number;
/
