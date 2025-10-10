-- execute the statement in SQL Developer using system schema

exec DBMS_MONITOR.CLIENT_ID_TRACE_ENABLE(client_id=>'C4', waits => TRUE, binds => FALSE);
