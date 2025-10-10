
# This script produces a file, and a fragment of that file is used on the slide

rm $ORACLE_BASE/diag/rdbms/orcl/orcl/trace/*code_03_30*.trc

sqlplus sh/sh <<-EOF

alter session set tracefile_identifier='code_03_30_';

EXEC DBMS_SESSION.SESSION_TRACE_ENABLE(waits => TRUE, binds => FALSE);

select max(cust_credit_limit) from customers where cust_city ='Paris';

EXEC DBMS_SESSION.SESSION_TRACE_DISABLE();

exit
EOF

tkprof $ORACLE_BASE/diag/rdbms/orcl/orcl/trace/*code_03_30*.trc output.txt SYS=NO

cat output.txt
