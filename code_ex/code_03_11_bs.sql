-- Use the hr schema to run the statement in SQL Developer

select * 
   from hr.employees natural join hr.departments
   where department_id = 10;
