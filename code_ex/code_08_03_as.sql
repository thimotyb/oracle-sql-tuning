--Use the scott schema to execute the SQL statement
--Run the clear_scott.sql script located in /home/oracle/labs/code_examp before executing this script
--Click on the EXPLAIN PLAN tool icon in the SQL Worksheet and verify the execution plan 

SELECT e.ename, d.dname
FROM dept d JOIN emp e USING (deptno)
WHERE e.job = 'ANALYST' OR e.empno = 9999;
 
