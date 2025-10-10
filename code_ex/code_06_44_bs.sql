--Use SQL *Plus to execute the SQL statement
--Login to SQL* PLUS as sysdba

set long 10000000
set longchunksize 10000000
set linesize 200
select dbms_sqltune.report_sql_monitor from dual;
