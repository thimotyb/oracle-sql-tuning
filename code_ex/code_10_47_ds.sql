--Use the sh schema to execute the SQL statement in SQL Developer

exec dbms_stats.publish_pending_stats('SH','CUSTOMERS');
