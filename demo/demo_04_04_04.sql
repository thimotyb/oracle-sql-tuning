REM demo04_04 

drop table times2;
create table times2 (time_id varchar2(10), day_name varchar2(9));
insert into times2 select time_id, day_name from times;
commit;
alter table times2 add constraint times2_pk primary key(time_id);

alter session set nls_date_format='DD-MON-RR';

alter session set tracefile_identifier='demo04_04';
alter session set sql_trace=true;

select day_name from times2 where time_id='07-FEB-99';
select day_name from times2 where time_id=to_date('07-FEB-99','DD-MON-RR');

alter session set sql_trace=false;
drop table times2;
