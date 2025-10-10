REM demo09_01
conn / as sysdba
alter system flush buffer_cache
/

conn hr/hr
alter session set tracefile_identifier='demo09_01';
alter session set sql_trace=true;

SELECT department_id, last_name, salary 
FROM employees e1 
WHERE salary > (SELECT AVG(salary) 
                FROM employees e2
                WHERE e1.department_id = e2.department_id
                GROUP BY e2.department_id) 
ORDER BY department_id
/

alter session set sql_trace=false;

