REM demo21_02

alter table products enable validate constraint products_pk;
   
create bitmap index sales_subcat_bjix on sales(p.prod_subcategory)
  from sales s, products p
 where s.prod_id = p.prod_id
 local;

alter session set tracefile_identifier='demo21_02';
alter session set sql_trace=true;

select /*+ index(s sales_subcat_bjix) */ sum(s.quantity_sold) 
  from sales s, products p
 where s.prod_id = p.prod_id
   and p.prod_subcategory = 'CD-ROM';  
   
alter session set sql_trace=false;
drop index sales_subcat_bjix;

