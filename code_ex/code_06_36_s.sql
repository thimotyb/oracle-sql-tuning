--Use the hr schema to execute the SQL statement in SQL Developer
-- Execute  all the statements one by one

exec DBMS_WORKLOAD_REPOSITORY.CREATE_SNAPSHOT ('ALL');

-- Execute the statement to get the SNAP_ID and DB_ID

SELECT SNAP_ID, DBID FROM DBA_HIST_SNAPSHOT;

-- Replace the  DB_ID in the SQL STATEMENT

Exec DBMS_WORKLOAD_REPOSITORY.DROP_SNAPSHOT_RANGE (low_snap_id => 22, high_snap_id => 32, dbid => <<'Please enter the DB_ID value'>>); 

-- Replace the  DB_ID in the SQL STATEMENT

Exec DBMS_WORKLOAD_REPOSITORY.MODIFY_SNAPSHOT_SETTINGS (retention => 43200, interval => 30, dbid => <<' Please enter the DB_ID value'>>); 
