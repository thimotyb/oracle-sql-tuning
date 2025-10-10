--Use the scott schema to execute the SQL statement in SQL Developer
 

drop index I_DEPTNO;

create index I_DEPTNO on EMP(deptno);

--Click on the EXPLAIN PLAN tool icon in the SQL Worksheet and verify the execution plan 

select * from emp
where sal > 1000 and deptno is not null
order by deptno;
