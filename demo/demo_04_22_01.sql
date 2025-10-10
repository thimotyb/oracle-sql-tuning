REM demo22_01 

create or replace procedure register_subcat (v_prod_category_id number, v_prod_subcategory varchar2) 
is 
  v_next_seq  number;
begin

  select max(prod_subcat_seq) + 1 into v_next_seq
    from categories
   where prod_category_id = v_prod_category_id;
    
  if sqlcode = 100 then
      insert into categories values (v_prod_category_id, 1, v_prod_subcategory);
  else
      insert into categories values (v_prod_category_id, v_next_seq, v_prod_subcategory);
  end if;
  
  commit;
  
end;
/

