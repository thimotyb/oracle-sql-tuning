#!/bin/bash

# Install SQLcl and populate SH schema with data
# This script is separate from setup-docker.sh because:
# - SQLcl download and installation takes time
# - SH data loading is large (918K sales records) and takes 5-10 minutes
# - Not all users need SH schema immediately
# - Can be run later when needed

set -e

CONTAINER_NAME="oracle21c"
CONTAINER_WORK_DIR="/tmp/oracle-workshop"
SQLCL_VERSION="latest"

echo "========================================="
echo "SQLcl Installation & SH Data Loading"
echo "========================================="
echo

# Check if Docker container is running
if ! sudo docker ps | grep -q "$CONTAINER_NAME"; then
    echo "ERROR: Oracle container '$CONTAINER_NAME' is not running"
    echo "Please start it with: sudo docker start $CONTAINER_NAME"
    exit 1
fi

# Check if SH schema structure exists
echo "Checking if SH schema exists..."
SH_EXISTS=$(sudo docker exec $CONTAINER_NAME bash -c "sqlplus -s / as sysdba <<EOF
SET HEADING OFF FEEDBACK OFF PAGESIZE 0
ALTER SESSION SET CONTAINER=XEPDB1;
SELECT COUNT(*) FROM dba_users WHERE username='SH';
EXIT;
EOF" | grep -v "Session altered" | tr -d ' \t\n\r')

if [ "$SH_EXISTS" != "1" ]; then
    echo "ERROR: SH schema not found. Please run setup-docker.sh first to create the schema structure."
    exit 1
fi

echo "✓ SH schema structure exists"
echo

# Check if SH data is already loaded
echo "Checking if SH data is already loaded..."
SH_SALES_COUNT=$(sudo docker exec $CONTAINER_NAME bash -c "sqlplus -s sh/sh@//localhost:1521/XEPDB1 <<EOF
SET HEADING OFF FEEDBACK OFF PAGESIZE 0
SELECT COUNT(*) FROM sales;
EXIT;
EOF" | tr -d ' \t\n\r')

if [ "$SH_SALES_COUNT" -gt "0" ]; then
    echo "✓ SH schema already has $SH_SALES_COUNT sales records"
    echo "Data appears to be already loaded. Exiting."
    exit 0
fi

echo "SH schema tables are empty. Proceeding with SQLcl installation and data loading."
echo

# Download SQLcl to host if not already present
echo "=== Downloading SQLcl ==="
SQLCL_ZIP="/tmp/sqlcl-latest.zip"
SQLCL_DIR="/tmp/sqlcl"

if [ ! -f "$SQLCL_ZIP" ]; then
    echo "Downloading SQLcl from Oracle..."
    wget -q --show-progress https://download.oracle.com/otn_software/java/sqldeveloper/sqlcl-latest.zip -O "$SQLCL_ZIP"
    echo "✓ SQLcl downloaded"
else
    echo "✓ SQLcl already downloaded at $SQLCL_ZIP"
fi

# Extract SQLcl on host
if [ ! -d "$SQLCL_DIR" ]; then
    echo "Extracting SQLcl..."
    unzip -q "$SQLCL_ZIP" -d /tmp/
    echo "✓ SQLcl extracted to $SQLCL_DIR"
else
    echo "✓ SQLcl already extracted at $SQLCL_DIR"
fi

# Install Java 11 in container (SQLcl requires Java 11+)
echo
echo "=== Checking Java version in container ==="

# Check if Java 11 or higher is already installed
if sudo docker exec $CONTAINER_NAME bash -c "ls -d /usr/lib/jvm/java-1*-openjdk* 2>/dev/null | head -1" >/dev/null 2>&1; then
    JAVA_PATH=$(sudo docker exec $CONTAINER_NAME bash -c "ls -d /usr/lib/jvm/java-1*-openjdk* 2>/dev/null | grep -E 'java-(11|17|21)' | head -1")
    if [ -n "$JAVA_PATH" ]; then
        echo "✓ Java 11+ already installed at $JAVA_PATH"
    else
        echo "Old Java version found. Installing Java 11..."
        sudo docker exec -u root $CONTAINER_NAME bash -c "yum install -y java-11-openjdk-headless"
        echo "✓ Java 11 installed"
    fi
else
    echo "Java not found. Installing Java 11..."
    sudo docker exec -u root $CONTAINER_NAME bash -c "yum install -y java-11-openjdk-headless"
    echo "✓ Java 11 installed"
fi

# Verify Java 11+ is available
JAVA_HOME_PATH=$(sudo docker exec $CONTAINER_NAME bash -c "ls -d /usr/lib/jvm/java-1*-openjdk* 2>/dev/null | grep -E 'java-(11|17|21)' | head -1" || echo "")
if [ -z "$JAVA_HOME_PATH" ]; then
    echo "ERROR: Java 11+ installation failed"
    exit 1
fi
echo "✓ Java location: $JAVA_HOME_PATH"

# Copy SQLcl to container
echo
echo "=== Installing SQLcl in container ==="
if sudo docker exec $CONTAINER_NAME test -d /opt/sqlcl; then
    echo "✓ SQLcl already exists in container"
else
    echo "Copying SQLcl to container..."
    sudo docker cp "$SQLCL_DIR" $CONTAINER_NAME:/opt/sqlcl
    echo "✓ SQLcl copied to container"
fi

# Fix permissions (SQLcl files need to be readable/executable)
echo "Fixing SQLcl permissions..."
sudo docker exec -u root $CONTAINER_NAME bash -c "chmod -R 755 /opt/sqlcl && chown -R oracle:oinstall /opt/sqlcl"
echo "✓ SQLcl permissions fixed"

# Verify SQLcl works
echo "Verifying SQLcl installation..."
SQLCL_VERSION_OUTPUT=$(sudo docker exec $CONTAINER_NAME bash -c "export JAVA_HOME=\$(ls -d /usr/lib/jvm/java-1*-openjdk* | grep -E 'java-(11|17|21)' | head -1) && /opt/sqlcl/bin/sql -version 2>&1 | head -1")
echo "✓ SQLcl version: $SQLCL_VERSION_OUTPUT"
echo

# Check if sample schemas are in container
if ! sudo docker exec $CONTAINER_NAME test -d "$CONTAINER_WORK_DIR/db-sample-schemas/sales_history"; then
    echo "ERROR: Sample schemas not found in container at $CONTAINER_WORK_DIR/db-sample-schemas"
    echo "Please run setup-docker.sh first to copy sample schemas to the container."
    exit 1
fi

# Check if CSV files exist
if ! sudo docker exec $CONTAINER_NAME test -f "$CONTAINER_WORK_DIR/db-sample-schemas/sales_history/sales.csv"; then
    echo "ERROR: SH CSV data files not found in container"
    echo "Please run setup-docker.sh first to copy sample schemas to the container."
    exit 1
fi

echo "✓ Sample schemas and CSV files found in container"
echo

# Create SQLcl-compatible installation script on host, then copy to container
echo "=== Creating SQLcl installation script ==="
cat > /tmp/install_sh_sqlcl.sql <<'SHSQLCL'
SET ECHO OFF
SET VERIFY OFF
SET HEADING OFF
SET FEEDBACK OFF
SET SERVEROUTPUT ON

WHENEVER SQLERROR EXIT SQL.SQLCODE

PROMPT
PROMPT ========================================
PROMPT Loading SH (Sales History) Data
PROMPT ========================================
PROMPT
PROMPT This will load approximately:
PROMPT   - 918,843 sales records
PROMPT   - 55,500 customers
PROMPT   - 82,112 cost records
PROMPT   - 1,826 time records
PROMPT   - 503 promotions
PROMPT
PROMPT This process may take 5-10 minutes...
PROMPT

ALTER SESSION SET CURRENT_SCHEMA=SH;
ALTER SESSION SET NLS_LANGUAGE=American;
ALTER SESSION SET NLS_TERRITORY=America;

SELECT 'Start time: ' || systimestamp FROM dual;

-- The sh_populate.sql script will use SQLcl's LOAD command
@@sh_populate.sql

SELECT 'End time: ' || systimestamp FROM dual;

PROMPT
PROMPT ========================================
PROMPT Verifying Data Load
PROMPT ========================================

SET HEADING ON
SET FEEDBACK OFF

SELECT 'channels' TableName, 5 Expected, count(1) Actual FROM channels
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

PROMPT
PROMPT ========================================
PROMPT SH Schema Data Loading Complete!
PROMPT ========================================
PROMPT
EXIT
SHSQLCL

# Copy the script to container
sudo docker cp /tmp/install_sh_sqlcl.sql $CONTAINER_NAME:$CONTAINER_WORK_DIR/db-sample-schemas/sales_history/

echo "✓ SQLcl installation script created and copied to container"
echo

# Run SQLcl to populate SH data
echo "=== Loading SH Schema Data (this will take 5-10 minutes) ==="
echo
sudo docker exec $CONTAINER_NAME bash -c "export JAVA_HOME=\$(ls -d /usr/lib/jvm/java-1*-openjdk* | grep -E 'java-(11|17|21)' | head -1) && \
cd $CONTAINER_WORK_DIR/db-sample-schemas/sales_history && \
/opt/sqlcl/bin/sql sys/Oracle123@//localhost:1521/XEPDB1 as sysdba @install_sh_sqlcl.sql"

echo
echo "========================================="
echo "SQLcl Installation & SH Data Loading Complete!"
echo "========================================="
echo
echo "SH schema is now fully populated with data."
echo "You can connect and query the data with:"
echo "  sudo docker exec -it oracle21c sqlplus sh/sh@//localhost:1521/XEPDB1"
echo
echo "Example queries:"
echo "  SELECT COUNT(*) FROM sales;      -- Should return 918,843"
echo "  SELECT COUNT(*) FROM customers;  -- Should return 55,500"
echo
