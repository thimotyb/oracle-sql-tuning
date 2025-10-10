REM demo19_01

alter session set tracefile_identifier='demo29_01';
alter session set sql_trace=true;

select sum(quantity_sold)
  from sales_np
 where time_id between to_date('19980101', 'yyyymmdd') and to_date('19981231', 'yyyymmdd');
 
select sum(quantity_sold)
  from sales
 where time_id between to_date('19980101', 'yyyymmdd') and to_date('19981231', 'yyyymmdd');
 
select /*+ parallel(sales,4) */ sum(quantity_sold)
  from sales
 where time_id between to_date('19980101', 'yyyymmdd') and to_date('19981231', 'yyyymmdd');
 
alter session set sql_trace=false;

drop table sales_np;

