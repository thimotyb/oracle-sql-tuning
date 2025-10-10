-- start a session in SQL*Plus or SQL developer
-- connect / as sysdba
--Run the below statement to find your SID and Serial_num

SELECT SID, SERIAL# FROM v$session;
