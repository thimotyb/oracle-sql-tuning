--Connect as user scott in SQL Developer to run the statement
-- Check the execution plan using EXPLAIN PLAN tool icon

SELECT * 
  FROM emp 
  WHERE job = 'CLERK' OR deptno = 10;
