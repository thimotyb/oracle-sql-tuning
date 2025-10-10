-- Use the scott schema to execute the SQL statement
-- Run statement by statement


CREATE VIEW emp_10 AS
     SELECT empno, ename, job, sal, comm, deptno 
     FROM emp 
     WHERE deptno = 10;

--Run the statement and click on the EXPLAIN PLAN tool icon in the SQL Worksheet and verify the execution plan 

SELECT empno FROM emp_10 WHERE empno > 7800;

-- drop the view

DROP VIEW emp_10;
