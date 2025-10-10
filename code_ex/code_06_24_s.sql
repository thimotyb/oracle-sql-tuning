--Use the hr schema to execute the SQL statement in SQL Developer
--Click on the EXPLAIN PLAN tool icon in the SQL Worksheet and verify the execution plan
--Click the Autotrace icon to check trace-related information 


select e.email, d.department_name
FROM employees e , departments d
WHERE email like 'A%';
