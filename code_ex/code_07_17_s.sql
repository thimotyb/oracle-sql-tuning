--Use the scott schema to execute the SQL statement in SQL Developer

Drop index I_DEPTNO;

--Run the statement to create an index

create index I_DEPTNO 
on EMP(deptno);
 
--Click on the EXPLAIN PLAN tool icon in the SQL Worksheet and verify the execution plan 

select /*+ INDEX(EMP I_DEPTNO) */ * 
from emp 
where deptno = 10 
and sal > 1000;



 
