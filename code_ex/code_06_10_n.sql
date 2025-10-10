--Use the hr schema to execute the SQL statement
--This command inserts the execution plan of the SQL statement in the plan table

EXPLAIN PLAN
FOR
SELECT e.last_name, d.department_name FROM hr.employees e, hr.departments d 
WHERE e.department_id =d.department_id;
