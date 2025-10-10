--Use the scott schema to execute the SQL statement in SQL Developer
--Click on the EXPLAIN PLAN tool icon in the SQL Worksheet and verify the execution plan 


select /*+ INDEX_FFS(EMP I_DEPTNO)  */ deptno 
from emp
where deptno is not null;
