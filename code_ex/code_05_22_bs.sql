-- Use the scott schema to execute the SQL statement
--Click on the EXPLAIN PLAN tool icon in the SQL Worksheet and verify the execution plan 

SELECT empno 
  FROM emp 
  WHERE deptno = 10 AND empno > 7800; 
