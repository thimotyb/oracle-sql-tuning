--Connect as user sh in SQL Developer to run the statement

create index cust_last_name_rix on customers(REVERSE(cust_last_name));

--Click on the EXPLAIN PLAN tool icon in the SQL Worksheet and verify the execution plan to check usage of INDEX.

select cust_first_name, cust_last_name 
from customers 
where reverse(cust_last_name) like 'gni%';
