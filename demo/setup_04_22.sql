REM setup22

create table categories  as 
select distinct prod_category_id, to_number(substr(prod_subcategory_id,-1,1)) prod_subcat_seq, prod_subcategory
  from products
 order by 1,2;

create index cat_ix on categories (prod_category_id, prod_subcat_seq);


