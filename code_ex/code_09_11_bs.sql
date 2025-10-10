--Use the scott schema to execute the SQL statement in SQL Developer
--Click on the EXPLAIN PLAN tool icon in the SQL Worksheet and verify the execution plan 

select v.*,d.dname from (select DEPTNO, sum(sal) SUM_SAL
from emp group by deptno) v, dept d  where v.deptno=d.deptno;


