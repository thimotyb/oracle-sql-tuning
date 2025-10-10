-- start a session in SQL*Plus or SQL developer
--disable tracing for the entire database 
--connect / as sysdba


EXEC dbms_monitor.DATABASE_TRACE_DISABLE();
