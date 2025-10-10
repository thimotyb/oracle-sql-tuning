--Use the hr schema to execute the SQL statement in SQL Developer
--Click on the EXPLAIN PLAN tool icon in the SQL Worksheet and verify the execution plan
-- In case Uncommitted transaction dialog box appears click yes option.

select e.email, d.department_name
FROM employees e , departments d
WHERE email like 'A%';
