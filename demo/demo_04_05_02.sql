REM demo05_02

drop index cust_marital_status_bix;
create bitmap index cust_marital_status_bix on customers(cust_marital_status);

alter session set tracefile_identifier='demo05_02';
alter session set sql_trace=true;

select count(*) from customers where cust_marital_status is null;
select count(*) from customers where cust_marital_status is not null;

select max(cust_year_of_birth) from customers where cust_marital_status is null;
select max(cust_year_of_birth) from customers where cust_marital_status is not null;

alter session set sql_trace=false;
drop index cust_marital_status_bix;


