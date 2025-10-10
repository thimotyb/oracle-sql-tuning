--Use the scott schema to execute the SQL statement in SQL Developer
--Click on the EXPLAIN PLAN tool icon in the SQL Worksheet and verify the execution plan 


select /*+ index(t notnullind2) */ col2 from nulltest t;
