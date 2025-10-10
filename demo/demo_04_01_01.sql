REM demo01_01

alter system flush buffer_cache
/
alter session set optimizer_mode=first_rows
/
alter session set tracefile_identifier='demo01_01'
/
alter session set sql_trace=true
/
select p.town_name, c.cust_last_name
  from customers c, postal_codes p
 where p.code1 = substr(c.cust_postal_code,1,2)
   and p.code2 = substr(c.cust_postal_code,3,3)
   and p.code1 = '67'
   and c.country_id = 52790
/
alter session set sql_trace=false
/
