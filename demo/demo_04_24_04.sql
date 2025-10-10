REM demo24_04

insert into products 
select prod_id + 2000, prod_name, prod_desc, prod_subcategory, prod_subcategory_id,prod_subcategory_desc,
       prod_category, prod_category_id, prod_category_desc, prod_weight_class, prod_unit_of_measure,
       prod_pack_size, supplier_id, prod_status, prod_list_price, prod_min_price,
       prod_total, prod_total_id, prod_src_id, prod_eff_from, prod_eff_to, prod_valid
  from products
 where prod_category='Photo';

alter session set tracefile_identifier='demo24_04';
alter session set sql_trace = true;

merge into costs C using (select * from products where prod_category='Photo') P
on (C.prod_id = P.prod_id)
when matched then
  update set C.unit_price = P.prod_list_price where C.unit_cost > 80
  delete where C.channel_id = 4
when not matched then
  insert (prod_id, time_id, promo_id, channel_id, unit_cost, unit_price) 
  values (P.prod_id, '01-May-1999', 999, 5, P.prod_min_price, P.prod_list_price);
  
alter session set sql_trace = false;

select sum(unit_price) from costs;

rollback;

