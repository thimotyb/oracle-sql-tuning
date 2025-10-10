--Connect as user scott in SQL Developer to run the statement
--Click on the EXPLAIN PLAN tool icon in the SQL Worksheet and verify the execution plan 

SELECT /*+ RULE */ ename,job,sal,dname 
FROM emp,dept
WHERE dept.deptno=emp.deptno and not exists(SELECT *
                                            FROM salgrade
                                            WHERE emp.sal between losal and hisal);
 
