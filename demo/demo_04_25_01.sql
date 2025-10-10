alter session set tracefile_identifier='demo25_01';
alter session set sql_trace=true;

select sum(amount_sold)
  from sales s, times t, customers c 
 where s.time_id  = t.time_id
   and s.cust_id  = c.cust_id
   and t.day_name = 'Friday' 
   and country_id = 52772;
 
select sum(amount_sold)
  from sales s, times t, products p 
 where s.time_id  = t.time_id
   and s.prod_id  = p.prod_id
   and t.day_name = 'Friday' 
   and prod_category = 'Electronics';
   
select sum(amount_sold)
  from sales s, times t, promotions p 
 where s.time_id  = t.time_id
   and s.promo_id = p.promo_id 
   and t.day_name = 'Friday' 
   and promo_category= 'TV';
   
alter session set sql_trace=false;

