--Use the scott schema to execute the SQL statement
--Click on the EXPLAIN PLAN tool icon in the SQL Worksheet and verify the execution plan 


select ename, e.deptno, d.deptno, d.dname
from emp e, dept d
where e.deptno = d.deptno and ename like 'A%';
