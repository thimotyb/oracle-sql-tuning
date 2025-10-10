
alter session set tracefile_identifier='demo15_01';
alter session set sql_trace=true;

alter system flush buffer_cache;

select count(*)
  from sales s, customers c
 where s.cust_id = c.cust_id
   and prod_id = 120 
   and c.cust_credit_limit > 10000;
  
alter system flush buffer_cache;

select 1
  from sales s
 where prod_id = 120 
   and exists (select 1 
                 from customers c
                where s.cust_id = c.cust_id
                  and c.cust_credit_limit > 10000)
and rownum =1;

alter system flush buffer_cache;

select 1
  from customers c
 where c.cust_credit_limit > 10000 
   and exists (select 1 
                 from sales s
                where s.cust_id = c.cust_id
                  and s.prod_id = 120)
and rownum =1;

   
alter session set sql_trace=false;
