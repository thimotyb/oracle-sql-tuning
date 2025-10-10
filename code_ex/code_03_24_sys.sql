
-- Login to SQL*Plus as sysdba and execute the statement 

exec DBMS_MONITOR.CLIENT_ID_TRACE_ENABLE( client_id=>'HR session', waits => FALSE, binds => FALSE);


--Execute the code_03_24_sess1.sql and code_03_24_sess2.sql script before executing the below SQL statement

exec DBMS_MONITOR.CLIENT_ID_TRACE_DISABLE( client_id => 'HR session');

exit
EOF

trcsess output=mytrace.trc clientid='HR session' $ORACLE_BASE/diag/rdbms/orcl/orcl/trace/*.trc


