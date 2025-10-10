--Use the hr schema to execute the SQL statement in SQL Developer
--This command inserts the execution plan of the SQL statement in the plan table and adds the optional demo01 name tag for future reference. 

EXPLAIN PLAN
SET STATEMENT_ID = 'demo01' FOR
 SELECT e.last_name, d.department_name   
 FROM hr.employees e, hr.departments d 
 WHERE e.department_id = d.department_id;

