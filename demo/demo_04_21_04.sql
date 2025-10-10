REM demo21_04

alter table customers enable validate constraint customers_pk;  

create bitmap index sales_subcat_city_bjix on sales(p.prod_subcategory, c.cust_city)
  from sales s, products p, customers c
 where s.prod_id = p.prod_id
   and s.cust_id = c.cust_id 
 local;

alter session set tracefile_identifier='demo21_04';
alter session set sql_trace=true;

select /*+ index(s sales_subcat_city_bjix) */ sum(s.quantity_sold) 
  from sales s, products p, customers c
 where s.prod_id = p.prod_id
   and s.cust_id = c.cust_id 
   and p.prod_subcategory = 'CD-ROM'
   and c.cust_city = 'Berkley';
   
alter session set sql_trace=false;

drop index sales_subcat_city_bjix;

