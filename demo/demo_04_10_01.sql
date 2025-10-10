alter session set tracefile_identifier='demo10_01';
alter session set sql_trace=true;

select count(*)
  from customers
 where cust_first_name = 'Max'  or cust_last_name = 'Colven'; -> 127 rows 

select count(*)
from (
select *
  from customers
 where cust_first_name = 'Max'
union 
select *
  from customers
 where cust_last_name = 'Colven'); -> 127 rows
 
select count(*)
from (
select *
  from customers
 where cust_first_name = 'Max'
union all
select *
  from customers
 where cust_last_name = 'Colven'); -> 143 rows
  
alter session set sql_trace=false;
