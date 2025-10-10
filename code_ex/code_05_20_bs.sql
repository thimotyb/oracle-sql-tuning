-- Use the scott schema to execute the SQL statement
-- Check the execution plan using EXPLAIN PLAN tool icon

SELECT * 
  FROM emp 
  WHERE job = 'CLERK' 
UNION ALL 
SELECT * 
  FROM emp 
  WHERE deptno = 10 AND job <> 'CLERK';
