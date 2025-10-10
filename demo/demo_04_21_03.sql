REM demo21_03

alter session set tracefile_identifier='demo21_03';
alter session set sql_trace=true;

select sum(s.quantity_sold) 
  from sales s, products p, customers c
 where s.prod_id = p.prod_id
   and s.cust_id = c.cust_id 
   and p.prod_subcategory = 'CD-ROM'
   and c.cust_city = 'Berkley';
   
alter session set sql_trace=false;

