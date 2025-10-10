--Use the scott schema to execute the SQL statement in SQL Developer
 


DROP VIEW V;
/
create view V as select /*+ NO_MERGE */ DEPTNO, sal  from emp ;
/

--Click on the EXPLAIN PLAN tool icon in the SQL Worksheet and verify the execution plan

select * from V;


