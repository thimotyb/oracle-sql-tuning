-- Use the scott schema to execute the SQL statement in SQL Developer
--Click on the EXPLAIN PLAN tool icon in the SQL Worksheet and verify the execution plan 

SELECT d.deptno,d.dname,e.empno,e.ename
FROM   emp e, dept d
WHERE  e.deptno(+)=d.deptno;
