--Use the scott schema to execute the SQL statement in SQL Developer
--Click on the EXPLAIN PLAN tool icon in the SQL Worksheet and verify the execution plan 

SELECT ename, emp.deptno, dept.deptno, dname
FROM emp, dept
WHERE ename like 'A%';
