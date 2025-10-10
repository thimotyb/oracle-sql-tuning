REM demo20_01.sql

select count(*) from customers;



select count(*)/55500 as country_selectivity from customers where country_id > 52772;



select count(*)/55500 as state_selectivity from customers where cust_state_province = 'NY';



select count(*)/55500 as city_selectivity from customers where cust_city='Belmont';


