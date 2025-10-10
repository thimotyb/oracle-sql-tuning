--Use the hr schema to execute the SQL statement in SQL Developer

--Execute the 1st query

SELECT e.last_name, d.department_name
FROM hr.employees e, hr.departments d 
WHERE  e.department_id =d.department_id;

select * from table(dbms_xplan.display);


-- Run the statement to retrieve the SQL_ID

SELECT SQL_ID, SQL_TEXT FROM V$SQL WHERE SQL_TEXT LIKE 'SELECT e.last_name,%' ;

--If you get more than two SQL_IDs then run the below statement 

alter system flush shared_pool;

--Replace the SQL_ID in the last SELECT query

SELECT PLAN_TABLE_OUTPUT FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(<<'Please enter the SQL_ID value'>>)); 
