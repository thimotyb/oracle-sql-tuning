--Use the scott schema to execute the SQL statement in SQL Developer



DROP INDEX IX_FBI;
/
create index IX_FBI on EMP(UPPER(ename));
/

--Click on the EXPLAIN PLAN tool icon in the SQL Worksheet and verify the execution plan

select * from emp where upper(ENAME) like 'A%';
 
