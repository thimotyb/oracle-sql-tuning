drop index cust_last_name_rix;

alter session set tracefile_identifier='demo16_01';
alter session set sql_trace=true;

select cust_first_name, cust_last_name
  from customers
 where cust_last_name like '%ing';

create index cust_last_name_rix on customers(REVERSE(cust_last_name));

select cust_first_name, cust_last_name
  from customers
 where reverse(cust_last_name) like 'gni%';
 
alter session set sql_trace=false;

drop index cust_last_name_rix;
