REM demo20_03.sql

drop   index cust_country_state_city_ix;
create index cust_city_state_country_ix on customers(cust_city, cust_state_province, country_id);

alter session set tracefile_identifier='demo20_03';
alter session set sql_trace=true;

select count(*) from customers
 where country_id > 52000
   and cust_state_province = 'CA'
   and cust_city = 'Belmont';
   
alter session set sql_trace=false;

drop   index cust_city_state_country_ix;
create index cust_country_state_city_ix on customers(country_id, cust_state_province, cust_city);

