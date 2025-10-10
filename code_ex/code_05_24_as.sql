-- Use the scott schema to execute the SQL statement
--Click on the EXPLAIN PLAN tool icon in the SQL Worksheet and verify the execution plan 

SELECT * 
 FROM emp, dept 
 WHERE emp.deptno = 20 AND emp.deptno = dept.deptno;
