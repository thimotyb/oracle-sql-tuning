-- Use the scott schema to execute the SQL statement in SQL Developer
--Click on the EXPLAIN PLAN tool icon in the SQL Worksheet and verify the execution plan 

SELECT deptno, dname FROM dept
WHERE deptno IS NOT NULL AND 
deptno NOT IN 
 (SELECT /*+ HASH_AJ */ deptno FROM emp WHERE deptno IS NOT NULL); 
