alter session set tracefile_identifier='demo12_01';
alter session set sql_trace=true;

select cust_id, cust_first_name, cust_last_name, cust_state_province 
  from customers
 where country_id between 52788 and 52790
   and cust_state_province like 'W%';
   
select /*+ index(c cust_country_state_city_ix) */ cust_id, cust_first_name, cust_last_name, cust_state_province 
  from customers c
 where country_id between 52788 and 52790
   and cust_state_province like 'W%';
  
select /*+ index(c cust_country_state_city_ix) */ cust_id, cust_first_name, cust_last_name, cust_state_province 
  from customers c
 where country_id in (52788, 52789, 52790)
   and cust_state_province like 'W%';

alter session set sql_trace=false;
