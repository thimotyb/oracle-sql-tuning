--Connect as user scott in SQL Developer to run the statement

alter session set statistics_level=ALL;


select /*+ RULE to make sure it reproduces 100% */ ename,job,sal,dname
from emp,dept where dept.deptno = emp.deptno and not exists (select * from salgrade where emp.sal between losal and hisal);


select * from table(dbms_xplan.display_cursor(null,null,'TYPICAL IOSTATS LAST'));
