alter session set tracefile_identifier='demo13_01';
alter session set sql_trace = true;

select sum(amount_sold)
  from sales
 where prod_id between 130 and 150
   and cust_id between 10000 and 10100;
   
select /*+ index(s sales_pk) */ sum(amount_sold)
  from sales s
 where prod_id between 130 and 150
   and cust_id between 10000 and 10100;
   
select sum(amount_sold)
  from products p, sales s
 where s.prod_id = p.prod_id 
   and p.prod_id between 130 and 150
   and s.cust_id between 10000 and 10100;

select /*+ ordered use_nl(p s) */ sum(amount_sold)
  from products p, sales s
 where s.prod_id = p.prod_id 
   and p.prod_id between 130 and 150
   and s.cust_id between 10000 and 10100;

alter session set sql_trace = false;
