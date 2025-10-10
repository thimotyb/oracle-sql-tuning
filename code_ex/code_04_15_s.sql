--Connect as user hr in SQL Developer to run the statement
--Click on the EXPLAIN PLAN tool icon in the SQL Worksheet and verify the execution plan.

SELECT department_id, last_name, salary 
FROM employees e1 
WHERE salary > (SELECT AVG(salary) 
                FROM employees e2
                WHERE e1.department_id =e2.department_id
                GROUP BY e2.department_id) 
ORDER BY department_id;
