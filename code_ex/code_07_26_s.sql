--Use the scott schema to execute the SQL statement in SQL Developer

drop index IX_SS;
alter table emp modify (SAL not null, ENAME not null);
drop index I_ENAME;
drop index I_SAL;
create index I_ENAME on EMP(ename);
create index I_SAL on EMP(sal);

--Click on the EXPLAIN PLAN tool icon in the SQL Worksheet and verify the execution plan

select /* +INDEX_JOIN(e) */ ename,  sal from emp e;
