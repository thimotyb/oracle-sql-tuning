--Use the sh schema to execute the SQL statement in SQL Developer

exec dbms_stats.gather_table_stats('SH','CUSTOMERS');

