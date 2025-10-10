--Use the scott schema to execute the SQL statement in SQL Developer
--Click on the EXPLAIN PLAN tool icon in the SQL Worksheet and verify the execution plan 

SELECT  deptno, sum(sal) SUM_SAL FROM emp 
GROUP BY deptno HAVING sum(sal) > 9000;
