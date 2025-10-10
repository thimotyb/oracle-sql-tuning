REM demo24_02

alter session set tracefile_identifier='demo24_02';
alter session set sql_trace = true;

insert all 
when cust_marital_status='single'  then into cust_single
when cust_marital_status='married' then into cust_married
select * from customers;

alter session set sql_trace = false;

rollback;

drop table cust_single;
drop table cust_married;

