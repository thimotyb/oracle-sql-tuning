set echo off
set heading off
set term off
set feed off

spool /home/oracle/demo/dbi.sql

select 'drop index '|| index_name || ';' from user_indexes where index_type='BITMAP';

spool off
set feed on
set heading on
set term on
set echo on

@/home/oracle/demo/dbi.sql
