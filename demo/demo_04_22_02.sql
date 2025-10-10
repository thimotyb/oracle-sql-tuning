REM demo23_02 

create or replace procedure register_subcat_new (v_prod_category_id number, v_prod_subcategory varchar2) 
is 
begin
  insert into categories
  select /*+ index_desc(C cat_ix) use_nl(A C) */
         v_prod_category_id, decode(C.prod_category_id, null, 1, C.prod_subcat_seq + 1), v_prod_subcategory
    from (select v_prod_category_id as prod_category_id from dual) A, categories C 
   where A.prod_category_id = C.prod_category_id (+)
     and rownum = 1;
     
  commit;
end;
/

