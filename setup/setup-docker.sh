#!/bin/bash

# Docker-compatible setup script for Oracle SQL Tuning Workshop
# This script copies files into the Docker container and runs setup scripts

set -e

REPO_DIR="/home/ubuntu/oracle-sql-tuning"
CONTAINER_NAME="oracle21c"
CONTAINER_WORK_DIR="/tmp/oracle-workshop"

echo "========================================="
echo "Oracle SQL Tuning Workshop Setup"
echo "========================================="
echo

# Check if Docker container is running
if ! sudo docker ps | grep -q "$CONTAINER_NAME"; then
    echo "ERROR: Oracle container '$CONTAINER_NAME' is not running"
    echo "Please start it with: sudo docker start $CONTAINER_NAME"
    exit 1
fi

echo "Copying workshop files to container..."
sudo docker exec $CONTAINER_NAME mkdir -p $CONTAINER_WORK_DIR
sudo docker cp $REPO_DIR/solutions $CONTAINER_NAME:$CONTAINER_WORK_DIR/
sudo docker cp $REPO_DIR/workshops $CONTAINER_NAME:$CONTAINER_WORK_DIR/
sudo docker cp $REPO_DIR/demo $CONTAINER_NAME:$CONTAINER_WORK_DIR/
sudo docker cp $REPO_DIR/code_ex $CONTAINER_NAME:$CONTAINER_WORK_DIR/

echo
echo "Downloading Oracle sample schemas..."
if [ ! -d "/tmp/db-sample-schemas" ]; then
    cd /tmp
    git clone https://github.com/oracle-samples/db-sample-schemas.git
    cd -
fi

echo "Copying sample schemas to container..."
sudo docker cp /tmp/db-sample-schemas $CONTAINER_NAME:$CONTAINER_WORK_DIR/

# Create automated install scripts on host
mkdir -p /tmp/sample-schema-installers

# Create HR install script
cat > /tmp/sample-schema-installers/install_hr_auto.sql <<'HRSQL'
SET ECHO OFF
SET VERIFY OFF
SET HEADING OFF
SET FEEDBACK OFF
SET SERVEROUTPUT ON
WHENEVER SQLERROR EXIT SQL.SQLCODE

PROMPT Installing HR (Human Resources) schema...

DECLARE
   v_user_exists   all_users.username%TYPE;
BEGIN
   SELECT MAX(username) INTO v_user_exists
      FROM all_users WHERE username = 'HR';
   IF v_user_exists IS NOT NULL THEN
      EXECUTE IMMEDIATE 'DROP USER HR CASCADE';
      DBMS_OUTPUT.PUT_LINE('Old HR schema has been dropped.');
   END IF;
END;
/

CREATE USER hr IDENTIFIED BY hr
               DEFAULT TABLESPACE USERS
               QUOTA UNLIMITED ON USERS;

GRANT CREATE MATERIALIZED VIEW,
      CREATE PROCEDURE,
      CREATE SEQUENCE,
      CREATE SESSION,
      CREATE SYNONYM,
      CREATE TABLE,
      CREATE TRIGGER,
      CREATE TYPE,
      CREATE VIEW,
      DBA
  TO hr;

ALTER SESSION SET CURRENT_SCHEMA=HR;
ALTER SESSION SET NLS_LANGUAGE=American;
ALTER SESSION SET NLS_TERRITORY=America;

PROMPT Creating HR schema objects...
@@hr_create.sql
PROMPT Populating HR tables with data...
@@hr_populate.sql
PROMPT Creating HR procedural objects...
@@hr_code.sql

PROMPT HR schema installation complete.
SET HEADING ON
SET FEEDBACK OFF

SELECT 'regions' AS "Table", 5 AS "Expected", count(1) AS "Actual" FROM hr.regions
UNION ALL
SELECT 'countries', 25, count(1) FROM hr.countries
UNION ALL
SELECT 'departments', 27, count(1) FROM hr.departments
UNION ALL
SELECT 'locations', 23, count(1) FROM hr.locations
UNION ALL
SELECT 'employees', 107, count(1) FROM hr.employees
UNION ALL
SELECT 'jobs', 19, count(1) FROM hr.jobs
UNION ALL
SELECT 'job_history', 10, count(1) FROM hr.job_history;

PROMPT HR schema successfully installed!
EXIT
HRSQL

# Create SH install script
cat > /tmp/sample-schema-installers/install_sh_auto.sql <<'SHSQL'
SET ECHO OFF
SET VERIFY OFF
SET HEADING OFF
SET FEEDBACK OFF
SET SERVEROUTPUT ON
WHENEVER SQLERROR EXIT SQL.SQLCODE

PROMPT Installing SH (Sales History) schema...

DECLARE
   v_user_exists   all_users.username%TYPE;
BEGIN
   SELECT MAX(username) INTO v_user_exists
      FROM all_users WHERE username = 'SH';
   IF v_user_exists IS NOT NULL THEN
      EXECUTE IMMEDIATE 'DROP USER SH CASCADE';
      DBMS_OUTPUT.PUT_LINE('Old SH schema has been dropped.');
   END IF;
END;
/

CREATE USER sh IDENTIFIED BY sh
               DEFAULT TABLESPACE USERS
               QUOTA UNLIMITED ON USERS;

GRANT CREATE MATERIALIZED VIEW,
      CREATE DIMENSION,
      CREATE PROCEDURE,
      CREATE SEQUENCE,
      CREATE SESSION,
      CREATE SYNONYM,
      CREATE TABLE,
      CREATE TRIGGER,
      CREATE TYPE,
      CREATE VIEW,
      DBA
  TO sh;

ALTER SESSION SET CURRENT_SCHEMA=SH;
ALTER SESSION SET NLS_LANGUAGE=American;
ALTER SESSION SET NLS_TERRITORY=America;

SELECT 'Start time: ' || systimestamp AS "Progress" FROM dual;
PROMPT Creating SH schema objects...
@@sh_create.sql
PROMPT Populating SH tables (this may take several minutes)...
@@sh_populate.sql
SELECT 'End time: ' || systimestamp AS "Progress" FROM dual;

PROMPT SH schema installation complete.
SET HEADING ON
SET FEEDBACK OFF

SELECT 'channels' AS "Table", 5 AS "Expected", count(1) AS "Actual" FROM channels
UNION ALL
SELECT 'costs', 82112, count(1) FROM costs
UNION ALL
SELECT 'countries', 35, count(1) FROM countries
UNION ALL
SELECT 'customers', 55500, count(1) FROM customers
UNION ALL
SELECT 'products', 72, count(1) FROM products
UNION ALL
SELECT 'promotions', 503, count(1) FROM promotions
UNION ALL
SELECT 'sales', 918843, count(1) FROM sales
UNION ALL
SELECT 'times', 1826, count(1) FROM times
UNION ALL
SELECT 'supplementary_demographics', 4500, count(1) FROM supplementary_demographics;

PROMPT SH schema successfully installed!
EXIT
SHSQL

# Create SQLcl data loading script
cat > /tmp/sample-schema-installers/load_sh_data.sql <<'SQLCL'
SET ECHO OFF
SET VERIFY OFF
SET SERVEROUTPUT ON
ALTER SESSION SET CURRENT_SCHEMA=SH;
ALTER SESSION SET NLS_LANGUAGE=American;
SELECT 'Loading SH data - Start time: ' || systimestamp FROM dual;
@@sh_populate.sql
SELECT 'Loading SH data - End time: ' || systimestamp FROM dual;
EXIT
SQLCL

# Copy install scripts to container
sudo docker cp /tmp/sample-schema-installers/install_hr_auto.sql $CONTAINER_NAME:$CONTAINER_WORK_DIR/db-sample-schemas/human_resources/
sudo docker cp /tmp/sample-schema-installers/install_sh_auto.sql $CONTAINER_NAME:$CONTAINER_WORK_DIR/db-sample-schemas/sales_history/
sudo docker cp /tmp/sample-schema-installers/load_sh_data.sql $CONTAINER_NAME:$CONTAINER_WORK_DIR/db-sample-schemas/sales_history/

echo
echo "=== Installing Java 11 and SQLcl in container ==="

# Install Java 11 in container (required for SQLcl)
echo "Installing Java 11 in container..."
sudo docker exec -u root $CONTAINER_NAME bash -c "
if ls -d /usr/lib/jvm/java-1*-openjdk* 2>/dev/null | grep -E 'java-(11|17|21)' >/dev/null 2>&1; then
    echo '✓ Java 11+ already installed'
else
    yum install -y java-11-openjdk-headless
    echo '✓ Java 11 installed'
fi
"

# Download SQLcl on host if not present
SQLCL_ZIP="/tmp/sqlcl-latest.zip"
if [ ! -f "$SQLCL_ZIP" ]; then
    echo "Downloading SQLcl..."
    wget -q --show-progress https://download.oracle.com/otn_software/java/sqldeveloper/sqlcl-latest.zip -O "$SQLCL_ZIP"
else
    echo "✓ SQLcl already downloaded"
fi

# Extract and copy SQLcl to container
if ! sudo docker exec $CONTAINER_NAME test -d /opt/sqlcl; then
    echo "Installing SQLcl in container..."
    cd /tmp
    unzip -q sqlcl-latest.zip
    sudo docker cp sqlcl $CONTAINER_NAME:/opt/
    sudo docker exec -u root $CONTAINER_NAME chmod -R 755 /opt/sqlcl
    rm -rf /tmp/sqlcl
    echo "✓ SQLcl installed to /opt/sqlcl in container"
else
    echo "✓ SQLcl already installed in container"
fi

echo
echo "Creating database users and schemas..."
echo

# Create setup script locally first
cat > /tmp/run_setup.sh <<'SETUPSCRIPT'
#!/bin/bash

WORK_DIR="/tmp/oracle-workshop"
cd $WORK_DIR

echo "=== Setting up Common Mistakes schema ==="
if [ -d "solutions/Common_Mistakes" ] && [ -f "solutions/Common_Mistakes/setup_rest.sh" ]; then
    cd solutions/Common_Mistakes
    chmod +x setup_rest.sh
    ./setup_rest.sh || echo "WARNING: Common Mistakes setup failed"
    cd $WORK_DIR
else
    echo "SKIP: Common Mistakes setup files not found"
fi

echo
echo "=== Setting up Explain Plan (EP) schema ==="
if [ -f "solutions/Explain_Plan/ep_setup.sql" ]; then
    cd solutions/Explain_Plan
    sqlplus sys/Oracle123@//localhost:1521/XEPDB1 as sysdba @ep_setup.sql || echo "WARNING: EP setup failed"
    cd $WORK_DIR
else
    echo "SKIP: Explain Plan setup files not found"
fi

echo "=== Creating EP TEST table ==="
sqlplus -s ep/ep@//localhost:1521/XEPDB1 <<EOF
SET SERVEROUTPUT ON FEEDBACK OFF
drop table test purge;

create table test(c number, d varchar2(500));

begin
for i in 1..20000 loop
insert into test values(1,'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
end loop;
commit;
end;
/

create index test_c_indx on test(c);

exec dbms_stats.gather_schema_stats('EP');

SELECT 'EP TEST table: ' || COUNT(*) || ' rows' FROM test;
EXIT;
EOF

echo
echo "=== Setting up Application Tracing (TRACE) schema ==="
if [ -f "solutions/Application_Tracing/at_setup.sql" ]; then
    cd solutions/Application_Tracing
    sqlplus sys/Oracle123@//localhost:1521/XEPDB1 as sysdba @at_setup.sql || echo "WARNING: Application Tracing setup failed"
    cd $WORK_DIR
else
    echo "SKIP: Application Tracing setup files not found"
fi

echo "=== Creating TRACE SALES tables (will run after SH is installed) ===
# Placeholder - will be created after SH installation below"

echo
echo "=== Setting up Access Paths ==="
if [ -d "solutions/Access_Paths" ]; then
    cd solutions/Access_Paths

    if [ -f "ap_setup.sql" ]; then
        sqlplus sys/Oracle123@//localhost:1521/XEPDB1 as sysdba @ap_setup.sql || echo "WARNING: ap_setup failed"
    fi

    if [ -f "idx_setup.sql" ]; then
        sqlplus sh/sh@//localhost:1521/XEPDB1 @idx_setup.sql || echo "WARNING: idx_setup failed"
    fi

    if [ -f "create_mysales_index.sql" ]; then
        sqlplus sh/sh@//localhost:1521/XEPDB1 @create_mysales_index.sql || echo "WARNING: create_mysales_index failed"
    fi

    cd $WORK_DIR
else
    echo "SKIP: Access Paths setup files not found"
fi

echo
echo "=== Creating SPM user ==="
sqlplus /nolog <<EOF
connect / as sysdba
alter session set container=XEPDB1;
set echo on
drop user spm cascade;
create user spm identified by spm;
grant dba to spm;
exit
EOF

echo
echo "=== Setting up Adaptive Cursor Sharing (ACS) schema ==="
if [ -f "solutions/Adaptive_Cursor_Sharing/acs_setup.sql" ]; then
    cd solutions/Adaptive_Cursor_Sharing
    sqlplus sys/Oracle123@//localhost:1521/XEPDB1 as sysdba @acs_setup.sql || echo "WARNING: ACS setup failed"
    cd $WORK_DIR
else
    echo "SKIP: ACS setup files not found"
fi

echo "=== Creating ACS EMP table ==="
sqlplus -s acs/acs@//localhost:1521/XEPDB1 <<EOF
SET SERVEROUTPUT ON FEEDBACK OFF
drop table emp purge;

create table emp
(
 empno   number,
 ename   varchar2(20),
 phone   varchar2(20),
 deptno  number
);

insert into emp
  with tdata as
      (select rownum empno
        from all_objects
        where rownum <= 1000)
  select rownum,
        dbms_random.string ('u', 20),
        dbms_random.string ('u', 20),
        case
           when rownum/100000 <= 0.001 then mod(rownum, 10)
           else 10
        end
   from tdata a, tdata b
  where rownum <= 100000;

commit;

create index emp_i1 on emp(deptno);

exec dbms_stats.gather_table_stats(null, 'EMP', METHOD_OPT => 'FOR COLUMNS DEPTNO SIZE 10', CASCADE => TRUE);

SELECT 'ACS EMP table: ' || COUNT(*) || ' rows' FROM emp;
EXIT;
EOF

echo
echo "=== Setting up Cursor Sharing (CS) schema ==="
if [ -f "solutions/Cursor_Sharing/cs_setup.sql" ]; then
    cd solutions/Cursor_Sharing
    sqlplus sys/Oracle123@//localhost:1521/XEPDB1 as sysdba @cs_setup.sql || echo "WARNING: CS setup failed"
    cd $WORK_DIR
else
    echo "SKIP: CS setup files not found"
fi

echo "=== Creating CS EMP table ==="
sqlplus -s cs/cs@//localhost:1521/XEPDB1 <<EOF
SET SERVEROUTPUT ON FEEDBACK OFF
drop table emp purge;

create table emp
(
 empno   number,
 ename   varchar2(20),
 phone   varchar2(20),
 deptno  number
);

insert into emp
  with tdata as
      (select rownum empno
        from all_objects
        where rownum <= 1000)
  select rownum,
        dbms_random.string ('u', 20),
        dbms_random.string ('u', 20),
        case
           when rownum/100000 <= 0.001 then mod(rownum, 10)
           else 10
        end
   from tdata a, tdata b
  where rownum <= 100000;

commit;

create index emp_i1 on emp(deptno);

execute dbms_stats.gather_table_stats(null, 'EMP', cascade => true);

SELECT 'CS EMP table: ' || COUNT(*) || ' rows' FROM emp;
EXIT;
EOF

echo
echo "=== Creating AST user ==="
sqlplus /nolog <<EOF
connect / as sysdba
alter session set container=XEPDB1;
drop user ast cascade;
create user ast identified by ast;
grant dba to ast;
exit
EOF

echo
echo "=== Installing Oracle Sample Schemas (HR, SH) ==="
if [ -d "db-sample-schemas" ]; then
    # Install HR
    echo "Installing HR (Human Resources) schema..."
    cd db-sample-schemas/human_resources
    sqlplus sys/Oracle123@//localhost:1521/XEPDB1 as sysdba @install_hr_auto.sql || echo "WARNING: HR installation failed"
    cd $WORK_DIR

    # Install SH schema structure (without data first)
    echo "Installing SH (Sales History) schema structure..."
    cd db-sample-schemas/sales_history
    sqlplus sys/Oracle123@//localhost:1521/XEPDB1 as sysdba @install_sh_auto.sql || echo "WARNING: SH schema structure creation failed"
    cd $WORK_DIR

    # Load SH data using SQLcl (load_sh_data.sql was already copied to container)
    echo
    echo "=== Loading SH Schema Data (this may take 5-10 minutes) ==="
    cd $WORK_DIR/db-sample-schemas/sales_history
    # Set JAVA_HOME to Java 11 for SQLcl (Oracle container has Java 8 by default)
    export JAVA_HOME=/usr/lib/jvm/jre-11-openjdk
    /opt/sqlcl/bin/sql sys/Oracle123@//localhost:1521/XEPDB1 as sysdba @load_sh_data.sql || echo "WARNING: SH data loading failed"
    cd $WORK_DIR

    # Now create TRACE tables (depends on SH.SALES)
    echo
    echo "=== Creating TRACE SALES tables ==="
    sqlplus -s trace/trace@//localhost:1521/XEPDB1 <<EOF
SET SERVEROUTPUT ON FEEDBACK OFF
drop table sales purge;
drop table sales2 purge;
drop table sales3 purge;

create table sales as select * from sh.sales WHERE ROWNUM <= 100000;

create table sales2 as select * from sh.sales WHERE ROWNUM <= 10000;

create table sales3 as select * from sh.sales WHERE ROWNUM <= 5000;

commit;

SELECT 'TRACE SALES table: ' || COUNT(*) || ' rows' FROM sales;
SELECT 'TRACE SALES2 table: ' || COUNT(*) || ' rows' FROM sales2;
SELECT 'TRACE SALES3 table: ' || COUNT(*) || ' rows' FROM sales3;
EXIT;
EOF
else
    echo "WARNING: Sample schemas directory not found, skipping HR and SH installation"
fi

echo
echo "=== Setting up Hints/IOT schema ==="
if [ -f "solutions/Hints/iot_setup.sql" ]; then
    cd solutions/Hints
    sqlplus sys/Oracle123@//localhost:1521/XEPDB1 as sysdba @iot_setup.sql || echo "WARNING: IOT setup failed"
    cd $WORK_DIR
else
    echo "SKIP: Hints/IOT setup files not found"
fi

echo
echo "=== Unlocking HR account ==="
sqlplus /nolog <<EOF
connect / as sysdba
alter session set container=XEPDB1;
alter user hr identified by hr account unlock;
grant dba to hr;
grant select_catalog_role to hr;
grant select any dictionary to hr;
exit
EOF

echo
echo "=== Granting ALTER SESSION to PUBLIC ==="
sqlplus /nolog <<EOF
connect / as sysdba
alter session set container=XEPDB1;
GRANT ALTER SESSION TO PUBLIC;
exit
EOF

echo
echo "=== Setting up Query Result Cache (QRC) ==="
if [ -d "solutions/Query_Result_Cache" ] && [ -f "solutions/Query_Result_Cache/result_cache_setup.sh" ]; then
    cd solutions/Query_Result_Cache
    chmod +x result_cache_setup.sh
    ./result_cache_setup.sh || echo "WARNING: QRC setup failed"
    cd $WORK_DIR
else
    echo "SKIP: QRC setup files not found"
fi

echo
echo "=== Creating SHC, NIC, and IC users ==="
if [ -d "solutions/Access_Paths" ]; then
    cd solutions/Access_Paths

    if [ -f "shc_setup.sql" ]; then
        sqlplus /nolog @shc_setup.sql || echo "WARNING: SHC setup failed"
    fi

    if [ -f "nic_setup.sql" ]; then
        sqlplus /nolog @nic_setup.sql || echo "WARNING: NIC setup failed"
    fi

    if [ -f "ic_setup.sql" ]; then
        sqlplus /nolog @ic_setup.sql || echo "WARNING: IC setup failed"
    fi

    cd $WORK_DIR
else
    echo "SKIP: Access Paths user setup files not found"
fi

echo
echo "=== Setting up System Statistics ==="
if [ -f "solutions/System_Stats/sysstats_setup.sql" ]; then
    cd solutions/System_Stats
    sqlplus sys/Oracle123@//localhost:1521/XEPDB1 as sysdba @sysstats_setup.sql || echo "WARNING: System Stats setup failed"
    cd $WORK_DIR
else
    echo "SKIP: System Stats setup files not found"
fi

echo
echo "=== Setting up Automatic Gather Stats ==="
if [ -f "solutions/Automatic_Gather_Stats/ags_setup.sql" ]; then
    cd solutions/Automatic_Gather_Stats
    sqlplus sys/Oracle123@//localhost:1521/XEPDB1 as sysdba @ags_setup.sql || echo "WARNING: AGS setup failed"
    cd $WORK_DIR
else
    echo "SKIP: AGS setup files not found"
fi

echo
echo "========================================="
echo "Setup Complete!"
echo "========================================="
SETUPSCRIPT

# Copy the setup script to the container
chmod +x /tmp/run_setup.sh
sudo docker cp /tmp/run_setup.sh $CONTAINER_NAME:$CONTAINER_WORK_DIR/run_setup.sh

# Run the script inside the container
echo
echo "Running setup inside container..."
echo
sudo docker exec $CONTAINER_NAME bash -c "cd $CONTAINER_WORK_DIR && ./run_setup.sh"

# Clean up local temp file
rm -f /tmp/run_setup.sh

echo
echo "========================================="
echo "Workshop Setup Complete!"
echo "========================================="
echo
echo "Created users and schemas with tables:"
echo "  - SPM (SQL Performance Management)"
echo "  - EP (Explain Plan) - TEST table with 20,000 rows"
echo "  - TRACE (Application Tracing) - SALES, SALES2, SALES3 tables"
echo "  - ACS (Adaptive Cursor Sharing) - EMP table with 100,000 rows"
echo "  - CS (Cursor Sharing) - EMP table with 100,000 rows"
echo "  - AST (Automatic Statistics Tuning)"
echo "  - HR (unlocked and configured with sample data)"
echo "  - SH (Sales History with sample data)"
echo "  - SHC, NIC, IC (Access Paths users)"
echo "  - QRC (Query Result Cache)"
echo
echo "All users have password same as username (e.g., spm/spm)"
echo
echo "Workshop files are available in container at:"
echo "  $CONTAINER_WORK_DIR"
echo
