--Connect as user scott in SQL Developer to run the statement
--Click on the EXPLAIN PLAN tool icon in the SQL Worksheet and verify the execution plan 

select /*+ USE_NL(d) use_nl(m) */ m.last_name as dept_manager,d.department_name, l.street_address
    from  hr.employees m  join hr.departments d on (d.manager_id = m.employee_id)
          natural join  hr.locations l
   where  l.city = 'Seattle';

