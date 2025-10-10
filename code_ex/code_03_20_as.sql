-- start a session in SQL*Plus or SQL developer
-- enable tracing for the entire database 
-- connect / as sysdba

EXEC dbms_monitor.DATABASE_TRACE_ENABLE(TRUE,TRUE);

-- be sure to turn this off with code_03_20_bs.sql
