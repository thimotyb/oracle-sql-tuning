--Use the scott schema to execute the SQL statement in SQL Developer
 
drop index I_DEPTNO;
drop index IX_D;

---Run the statement to create an index

create index IX_D on EMP(deptno desc);

--Click on the EXPLAIN PLAN tool icon in the SQL Worksheet and verify the execution plan

select * from emp where deptno <30;
