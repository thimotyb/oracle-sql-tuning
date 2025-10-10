#!/bin/sh

#check the setup of the SQL_TUNE class module

#database is installed

if [ -d $ORACLE_HOME ] 
then 
	echo "ORACLE_HOME exists"
else
	echo "ORACLE_HOME does not exist"
	echo "ORACLE_HOME is set to : $ORACLE_HOME"
	exit 1
fi

if [ -e $ORACLE_HOME/bin/oracle ] 
then 
	echo "The oracle executable exists"
else
	echo "The oracle executable does not exist: Assume Install failed"
	exit 2
fi

ora_proc_count=`pgrep -lf orcl | wc -l`

if (( $ora_proc_count < 3 )) 
then
	echo " The ORCL instance is not started "
	exit 3 
fi

sqlplus /nolog <<-EOF
connect / as sysdba

PROMPT You should see 18 users including SH, OE, HR, and SCOTT
PROMPT with account status OPEN following:

SELECT username, account_status from DBA_USERS
WHERE account_status = 'OPEN'
AND username NOT IN ('SYS','SYSTEM','DBSNMP','MGMT_VIEW','SYSMAN');

column file_name Format A45 
column Autoextensible heading AUTOEXTEND FORMAT A10
column maxsize format A10
PROMPT You should see a tempfile with AUTOEXTEND On and 800MB maxsize
select file_name, Autoextensible, To_CHAR(maxbytes/1024/1024)||'MB' AS MAXSIZE from DBA_TEMP_FILES;

exit;
EOF

if [ -d /opt/sqldeveloper ] 
then
	echo 'SQL Developer installed'
else
	echo 'SQL Developer NOT installed'
fi

if [ -d /usr/java/jdk1.6.0_20 ]
then
	echo 'Proper Java version installed'
else
	echo 'Java 1.6.0 u 20 is not installed'
fi

sqldev_icon=`grep Icon=/opt/sqldeveloper/icon.png $HOME/Desktop/SQL* |wc -l`
if (( $sqldev_icon < 1 )) 
then
	echo 'SQL Developer desktop icon not installed'
fi

sqldev_conf=`grep /usr/java/jdk1.6.0_20 /opt/sqldeveloper/sqldeveloper/bin/sqldeveloper.conf | wc -l`
if (( $sqldev_conf < 1 )) 
then
	echo 'SQL developer not configured for java 1.6.0_20'
fi

timezone_setting=`env|grep TZ`
if [[ ${timezone_setting}=="TZ=GMT" ]] 
then 
	echo 'Timezone setting correct'
else
	echo 'set environment variable TZ=GMT'
fi 
