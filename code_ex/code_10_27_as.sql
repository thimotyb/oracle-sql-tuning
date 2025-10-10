--Use the sh schema to execute the SQL statement in SQL Developer

EXECUTE DBMS_STATS.GATHER_SYSTEM_STATS(gathering_mode => 'START');
