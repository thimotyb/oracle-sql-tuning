drop table sales_friday;
   
create GLOBAL TEMPORARY TABLE sales_friday (prod_id, cust_id, promo_id, amount_sold) on commit preserve rows
    as 
select prod_id, cust_id, promo_id, amount_sold 
  from sales s, times t
 where s.time_id = t.time_id
   and t.day_name = 'Friday';

alter session set tracefile_identifier='demo25_02';
alter session set sql_trace=true;
   
select sum(amount_sold)
  from sales_friday s, customers c
 where s.cust_id  = c.cust_id
   and country_id = 52772;

select sum(amount_sold)
  from sales_friday s, products p 
 where s.prod_id  = p.prod_id
   and prod_category = 'Electronics';
   
select sum(amount_sold)
  from sales_friday s, promotions p 
 where s.promo_id = p.promo_id 
   and promo_category= 'TV';
   
alter session set sql_trace=false;

