REM demo24_01

create table cust_single as 
select *   from customers where 1=2;

create table cust_married as 
select *   from customers where 1=2;

alter session set tracefile_identifier='demo24_01';
alter session set sql_trace = true;

insert into cust_single
select * from customers where cust_marital_status='single';

insert into cust_married
select * from customers where cust_marital_status='married';

alter session set sql_trace = false;

rollback;


