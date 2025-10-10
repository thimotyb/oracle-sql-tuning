--Use the hr schema to execute the SQL statement in SQL Developer

variable job_id varchar2(10)
exec :job_id := 'AD_VP';

select count(*) from employees where job_id = :job_id;
