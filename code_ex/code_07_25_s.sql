--Use the scott schema to execute the SQL statement in SQL Developer


drop index IX_SS;

create index IX_SS on EMP(DEPTNO,SAL);

--Click on the EXPLAIN PLAN tool icon in the SQL Worksheet and verify the execution plan

select /*+ index_ss(EMP IX_SS) */ * from emp where SAL < 1500;

