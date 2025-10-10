
conn / as sysdba
alter system flush buffer_cache;

conn hr/hr
alter session set tracefile_identifier='demo09_02';
alter session set sql_trace=true;

SELECT employee_id, last_name, salary
FROM employees e1
          , (SELECT avg(salary) avg_sal, department_id
             FROM employees
             GROUP BY department_id) a
WHERE e1.salary > a.avg_sal
AND e1.department_id = a.department_id
/

alter session set sql_trace=false;

