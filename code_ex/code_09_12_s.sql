--Use the scott schema to execute the SQL statement in SQL Developer
--Click on the EXPLAIN PLAN tool icon in the SQL Worksheet and verify the execution plan 

SELECT count(*)
FROM (SELECT /*+ NO_MERGE */ *
         FROM emp WHERE empno ='1' and rownum < 10);

