--Use the scott schema to execute the SQL statement
--Click on the EXPLAIN PLAN tool icon in the SQL Worksheet and verify the execution plan 

SELECT e.ename, e.sal, s.grade
FROM   emp e ,salgrade s
WHERE  e.sal = s.hisal;
