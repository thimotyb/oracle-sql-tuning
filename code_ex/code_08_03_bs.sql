-- Use the scott schema to execute the SQL statement
--Click on the EXPLAIN PLAN tool icon in the SQL Worksheet and verify the execution plan 


SELECT e.ename,d.dname
FROM   emp e, dept d
WHERE  e.deptno = d.deptno AND (e.job = 'ANALYST' OR e.empno = 9999);
