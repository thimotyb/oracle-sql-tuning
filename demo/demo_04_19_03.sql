create index cust_year_ix on customers(cust_year_of_birth);
alter session set tracefile_identifier='demo19_03';
alter session set sql_trace=true;

select /*+ index(c cust_year_ix) */ cust_state_province, sum(s.amount_sold) 
  from sales s, customers c
 where s.cust_id = c.cust_id 
   and c.cust_year_of_birth= 1988 
 group by cust_state_province;

alter session set sql_trace=false;
drop index cust_year_ix;
