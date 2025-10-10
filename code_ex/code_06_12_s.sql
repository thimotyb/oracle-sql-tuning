---Use the scott schema to execute the SQL statement in SQL Developer
--This command inserts the execution plan of the SQL statement in the plan table and adds the optional demo01 name tag for future reference


EXPLAIN PLAN SET STATEMENT_ID = 'demo01' FOR SELECT * FROM emp
WHERE ename = 'KING';

-- The DISPLAY function of the DBMS_XPLAN package can be used to format and display the last statement stored in PLAN_TABLE

 
SET LINESIZE 130
SET PAGESIZE 0 
select * from table(DBMS_XPLAN.DISPLAY());

