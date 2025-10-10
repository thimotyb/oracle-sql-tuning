REM demo21_01

alter session set tracefile_identifier='demo_21_01';
alter session set sql_trace=true;

select sum(s.quantity_sold) 
  from sales s, products p
 where s.prod_id = p.prod_id
   and p.prod_subcategory = 'CD-ROM';  
   
alter session set sql_trace=false;

