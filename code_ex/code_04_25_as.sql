--use the hr schema to execute the given SQL statement

CREATE OR REPLACE VIEW emp_dept
AS 
SELECT d.department_id, d.department_name, d.location_id,  
e.employee_id, e.last_name, e.first_name, e.salary,  e.job_id
FROM  departments d  ,employees e
WHERE e.department_id (+) = d.department_id; 


