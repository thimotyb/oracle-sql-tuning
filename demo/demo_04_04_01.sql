REM demo04_01 


alter session set tracefile_identifier='demo04_01';
alter session set sql_trace=true;

select cust_last_name from customers where cust_id= 200;
select cust_last_name from customers where cust_id=  200 ;

alter session set sql_trace=false;
