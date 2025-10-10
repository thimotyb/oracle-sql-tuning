
drop table postal_codes
/

create table postal_codes 
(code1 char(2),
 code2 char(3),
 town_name varchar2(30))
/ 

alter table postal_codes add constraint postal_codes_pk primary key(code1,code2)
/
 
insert into postal_codes
select substr(cust_postal_code,1,2), substr(cust_postal_code,3,3), 'NAME'||to_char(rownum)
  from (select distinct cust_postal_code
          from customers)
/
commit
/

exec dbms_stats.gather_table_stats('sqlt', 'postal_codes')
/
