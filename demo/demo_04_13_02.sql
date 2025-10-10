alter session set tracefile_identifier='demo13_02';
alter session set sql_trace = true;

select sum(amount_sold)
  from sales
 where prod_id between 20 and 150
   and cust_id between 10000 and 20000;
   
select /*+ index(s sales_pk) */ sum(amount_sold)
  from sales s
 where prod_id between 20 and 150
   and cust_id between 10000 and 20000;
   
select sum(amount_sold)
  from products p, sales s
 where s.prod_id = p.prod_id 
   and p.prod_id between 20 and 150
   and s.cust_id between 10000 and 20000;

select /*+ ordered use_nl(p s) */ sum(amount_sold)
  from products p, sales s
 where s.prod_id = p.prod_id 
   and p.prod_id between 20 and 150
   and s.cust_id between 10000 and 20000;

alter session set sql_trace = false;
