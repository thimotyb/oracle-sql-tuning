REM demo04_03 

REM time_id : date type

alter session set nls_date_format='DD-MON-RR';

alter session set tracefile_identifier='demo04_03';
alter session set sql_trace=true;

select day_name from times where time_id='07-FEB-99';
select day_name from times where time_id=to_date('07-FEB-99','DD-MON-RR');
