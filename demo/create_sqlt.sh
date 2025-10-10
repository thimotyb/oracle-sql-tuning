#!/bin/ksh

sqlplus / as sysdba <<EOF!

set echo on

startup force

drop directory sh_dir;

create directory sh_dir as '/home/oracle/demo';

grant all on directory sh_dir to sh;

drop user sqlt cascade;

drop tablespace sqlt including contents and datafiles;

//Remove the sqlt.dbf file if it already exists in the code_examp folder

create tablespace sqlt datafile '/home/oracle/demo/sqlt.dbf' size 150M;

create user sqlt identified by oracle_4U default tablespace sqlt;

grant dba to sqlt;

host rm /home/oracle/demo/sh.dmp

host expdp sh/sh directory=sh_dir dumpfile=sh.dmp logfile=shexp.log schemas=sh exclude=function, materialized_views exclude=table:\"IN \(\'MYSALES\', \'SALES1\'\)\" exclude=index:\"IN \(\'SUP_TEXT_IDX\'\)\"

host impdp system/oracle_4U directory=sh_dir dumpfile=sh.dmp logfile=shimp_log remap_schema=sh:sqlt remap_tablespace=example:sqlt table_exists_action=replace


conn sqlt/oracle_4U

host rm -rf /home/oracle/demo/dbi.sql

@/home/oracle/demo/dbix.sql

alter table sales add constraint sales_pk primary key (prod_id, cust_id, time_id, channel_id, promo_id);

alter table costs add constraint costs_pk primary key (prod_id, time_id, promo_id, channel_id);

create index cust_first_name_ix on customers(cust_first_name);

create index cust_last_name_ix on  customers(cust_last_name);

create index cust_postal_code_idx on customers(cust_postal_code);

exec dbms_stats.gather_schema_stats('SQLT', cascade => TRUE);

EOF!
