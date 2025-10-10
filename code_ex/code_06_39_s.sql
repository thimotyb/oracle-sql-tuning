--Use the hr schema to run the statement in SQL DEVELOPER

select /* example */ * from hr.employees natural
join hr.departments;

--Run the statement to get the SQL_ID

select sql_id, sql_text 
from v$SQL  where sql_text  like '%example%';

--Replace the SQL_ID in the last query
--Using the SQL_ID, verify that this statement has been captured in the DBA_HIST_SQLTEXT dictionary view. If the query does not return rows, it indicates that the statement has not yet been loaded in the AWR.

SELECT SQL_ID, SQL_TEXT FROM dba_hist_sqltext 
where sql_id='<<Please enter the SQL_ID value>>';

--You can take a manual AWR snapshot rather than wait for the next snapshot (which occurs every hour). Then check to see if it has been captured in DBA_HIST_SQLTEXT

exec dbms_workload_repository.create_snapshot;

--Replace the SQL_ID in the last query

SELECT PLAN_TABLE_OUTPUT FROM TABLE (DBMS_XPLAN.DISPLAY_AWR(<<'Please enter the SQL_ID value'>>)); 
 
--Use the DBMS_XPLAN.DISPLAY_AWR () function to retrieve the execution plan

SELECT PLAN_TABLE_OUTPUT FROM TABLE (DBMS_XPLAN.DISPLAY_AWR(<<'Please enter the SQL_ID value'>>)); 
