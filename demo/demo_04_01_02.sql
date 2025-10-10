REM demo01_02

alter system flush buffer_cache
/
create table customers2 as select * from customers
/

alter  table customers2 add (code1 char(2), code2 char(3))
/

update customers2 
   set code1=substr(cust_postal_code,1,2),
       code2=substr(cust_postal_code,3,3)
/
commit
/

create index cust2_code1_code2_idx on customers2 (code1,code2)
/

exec dbms_stats.gather_table_stats('sqlt', 'customers2')
/

alter session set tracefile_identifier='demo01_02'
/

alter session set sql_trace=true
/

select p.town_name, c.cust_last_name
  from customers2 c, postal_codes p
 where p.code1 = c.code1
   and p.code2 = c.code2
   and p.code1 = '67'
   and c.country_id = 52790
/

alter session set sql_trace=false
/
