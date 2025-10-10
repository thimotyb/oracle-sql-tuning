--Use the hr schema to execute the SQL statement in SQL Developer

variable job varchar2(6)
exec :job := 'AD_ASST'
select count(*), max(salary) 
from employees 
where job_id =:job;
