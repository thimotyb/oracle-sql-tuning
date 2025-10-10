--Use the oe schema to execute the SQL statement in SQL Developer 

BEGIN 
  DBMS_STATS.DELETE_TABLE_STATS('OE','ORDERS'); 
  DBMS_STATS.LOCK_TABLE_STATS('OE','ORDERS');
END;


