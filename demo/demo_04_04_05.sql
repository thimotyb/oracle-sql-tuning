REM demo04_05  

alter session set nls_date_format='YYYY-MM-DD';
alter session set tracefile_identifier='demo04_05';
alter session set sql_trace=true;
select day_name from times where time_id='1999-02-07';
alter session set sql_trace=false;

select day_name from times where time_id=to_date('1999-02-07','YYYY-MM-DD');

