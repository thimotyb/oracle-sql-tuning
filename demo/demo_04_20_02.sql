REM demo20_02.sql

alter session set tracefile_identifier='demo20_02';
alter session set sql_trace=true;

select count(*) from customers
 where country_id > 52000
   and cust_state_province = 'CA'
   and cust_city = 'Belmont';
   
alter session set sql_trace=false;
