drop materialized view mv1;

alter session set tracefile_identifier='demo27_01';
alter session set sql_trace=true;

select p.prod_name, t.week_ending_day, sum(s.amount_sold) sum_amount
  from sales s, products p, times t
 where s.time_id = t.time_id 
   and s.prod_id = p.prod_id
 group by p.prod_name, t.week_ending_day;

select p.prod_name, t.week_ending_day, sum(amount_sold)
  from sales s, products p, times t
 where s.time_id=t.time_id   
   and s.prod_id = p.prod_id 
   and t.week_ending_day between '01-AUG-1999' and '10-AUG-1999'
 group by prod_name, week_ending_day;

alter session set sql_trace=false;

