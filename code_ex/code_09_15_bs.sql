--Use the scott schema to execute the SQL statement in SQL Developer
--Click on the EXPLAIN PLAN tool icon in the SQL Worksheet and verify the execution plan 

SELECT deptno, dname FROM dept d WHERE NOT EXISTS (select 1 from emp e where e.deptno=d.deptno);
