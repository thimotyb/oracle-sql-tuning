
REM demo24_03

insert into products 
select prod_id + 2000, prod_name, prod_desc, prod_subcategory, prod_subcategory_id,prod_subcategory_desc,
       prod_category, prod_category_id, prod_category_desc, prod_weight_class, prod_unit_of_measure,
       prod_pack_size, supplier_id, prod_status, prod_list_price, prod_min_price,
       prod_total, prod_total_id, prod_src_id, prod_eff_from, prod_eff_to, prod_valid
  from products
 where prod_category='Photo';

alter session set tracefile_identifier='demo24_03';
alter session set sql_trace = true;

update costs C
   set unit_price = (select prod_list_price
                       from products P
                      where P.prod_id = C.prod_id)
 where unit_cost > 80 
   and prod_id in (select prod_id from products where prod_category='Photo');

delete from costs
 where unit_cost > 80 
   and prod_id in (select prod_id from products where prod_category='Photo')
   and channel_id = 4;

insert into costs 
select prod_id, '01-May-1999', 999, 5, prod_min_price, prod_list_price
  from products 
 where prod_id not in (select prod_id from costs)
   and prod_category='Photo';
   
alter session set sql_trace = false;

select sum(unit_price) from costs;
rollback;

