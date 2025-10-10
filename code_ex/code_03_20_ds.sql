-- start a session in SQL*Plus or SQL developer
-- connect / as sysdba
-- find the session id and serial number in EM or v$Session using the code_03_20_b1s.sql script
-- then issue the following for that session id and serial# 



EXEC dbms_monitor.SESSION_TRACE_DISABLE(session_id =>'ENTER SID', serial_num=>'ENTER SERIAL_NUM');

