
drop index costs_test_ix;

alter session set tracefile_identifier='demo18_01';
alter session set sql_trace=true;

alter system flush buffer_cache;

select prod_id, time_id, promo_id, channel_id, unit_cost
  from costs
 where prod_id = 120;
 
create index costs_test_ix on costs(prod_id, time_id, promo_id, channel_id, unit_cost);

alter system flush buffer_cache;

select prod_id, time_id, promo_id, channel_id, unit_cost
  from costs
 where prod_id = 120; 
 
alter session set sql_trace=false;

drop index costs_test_ix;


