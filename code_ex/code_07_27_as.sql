--Use the scott schema to execute the SQL statement in SQL Developer
 
create table nulltest ( col1 number, col2 number not null);
drop index nullind1;
drop index notnullind1;
create index nullind1 on nulltest (col1);
create index notnullind2 on nulltest (col2);

--Click on the EXPLAIN PLAN tool icon in the SQL Worksheet and verify the execution plan

select /*+ index(t nullind1) */ col1 from nulltest t;
