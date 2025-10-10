create index sales_cust_id_ix on sales(cust_id);
alter session set tracefile_identifier='demo19_02';
alter session set sql_trace=true;

select /*+ index(s sales_cust_id_ix) */ cust_state_province, sum(s.amount_sold) 
  from sales s, customers c
 where s.cust_id = c.cust_id 
   and c.cust_year_of_birth= 1988 
 group by cust_state_province;

alter session set sql_trace=false;
drop index sales_cust_id_ix;
