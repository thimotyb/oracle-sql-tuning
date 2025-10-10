REM demo01_03

alter system flush buffer_cache
/

alter session set tracefile_identifier='demo01_03'
/

alter session set sql_trace=true
/

select /*+ index(c cust2_code1_code2_idx) */ p.town_name, c.cust_last_name
  from customers2 c, postal_codes p
 where p.code1 = c.code1
   and p.code2 = c.code2
   and p.code1 = '67'
   and c.country_id = 52790
/

alter session set sql_trace=false
/

drop table postal_codes
/
drop table customers2
/
