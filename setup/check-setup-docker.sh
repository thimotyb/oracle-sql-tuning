#!/bin/bash

# Docker-compatible setup verification script for Oracle SQL Tuning Workshop
# Checks that the Oracle container and all workshop users/schemas are properly configured

set -e

CONTAINER_NAME="oracle21c"
REQUIRED_USERS=("SPM" "EP" "TRACE" "ACS" "CS" "AST" "HR" "QRC")

echo "========================================="
echo "Oracle SQL Tuning Workshop Setup Check"
echo "========================================="
echo

# Check 1: Docker is installed
echo "[1/8] Checking Docker installation..."
if command -v docker &> /dev/null; then
    echo "✓ Docker is installed: $(docker --version)"
else
    echo "✗ ERROR: Docker is not installed"
    exit 1
fi

# Check 2: Oracle container exists and is running
echo
echo "[2/8] Checking Oracle container..."
if sudo docker ps | grep -q "$CONTAINER_NAME"; then
    CONTAINER_STATUS=$(sudo docker inspect -f '{{.State.Health.Status}}' $CONTAINER_NAME 2>/dev/null || echo "no health check")
    echo "✓ Container '$CONTAINER_NAME' is running"
    if [ "$CONTAINER_STATUS" = "healthy" ]; then
        echo "✓ Container health status: healthy"
    else
        echo "⚠ Container health status: $CONTAINER_STATUS"
    fi
else
    echo "✗ ERROR: Container '$CONTAINER_NAME' is not running"
    echo "  Start it with: sudo docker start $CONTAINER_NAME"
    exit 2
fi

# Check 3: Database is responding
echo
echo "[3/8] Checking database connectivity..."
if sudo docker exec $CONTAINER_NAME sqlplus -s / as sysdba <<EOF > /dev/null 2>&1
SELECT 1 FROM DUAL;
EXIT;
EOF
then
    echo "✓ Database is accessible"
else
    echo "✗ ERROR: Cannot connect to database"
    exit 3
fi

# Check 4: Database version and status
echo
echo "[4/8] Checking database version and status..."
sudo docker exec $CONTAINER_NAME bash -c "echo 'SELECT banner FROM v\$version;' | sqlplus -s / as sysdba" | grep "Oracle Database"
echo
sudo docker exec $CONTAINER_NAME bash -c "cat <<EOF | sqlplus -s / as sysdba
SET HEADING OFF FEEDBACK OFF
SELECT 'Instance: ' || instance_name || ' - Status: ' || status FROM v\\\$instance;
SELECT 'Database: ' || name || ' - Mode: ' || open_mode FROM v\\\$database;
EXIT;
EOF" | grep -E "Instance|Database"

# Check 5: Pluggable databases
echo
echo "[5/8] Checking pluggable databases..."
PDB_STATUS=$(sudo docker exec $CONTAINER_NAME bash -c "echo 'SELECT name, open_mode FROM v\$pdbs WHERE name='\''XEPDB1'\'';' | sqlplus -s / as sysdba")
if echo "$PDB_STATUS" | grep -q "READ WRITE"; then
    echo "✓ XEPDB1 is open in READ WRITE mode"
else
    echo "✗ WARNING: XEPDB1 may not be in READ WRITE mode"
    echo "$PDB_STATUS"
fi

# Check 6: Required users exist
echo
echo "[6/8] Checking workshop users..."
echo
echo "Expected users with OPEN status:"
for user in "${REQUIRED_USERS[@]}"; do
    printf "  %-10s: " "$user"
    USER_STATUS=$(sudo docker exec $CONTAINER_NAME bash -c "cat <<EOF | sqlplus -s / as sysdba
SET HEADING OFF FEEDBACK OFF PAGESIZE 0
ALTER SESSION SET CONTAINER=XEPDB1;
SELECT account_status FROM dba_users WHERE username='$user';
EXIT;
EOF" | grep -v "Session altered" | tr -d ' \n\r')

    if [ "$USER_STATUS" = "OPEN" ]; then
        echo "✓ OPEN"
    elif [ -z "$USER_STATUS" ]; then
        echo "✗ NOT FOUND"
    else
        echo "⚠ $USER_STATUS"
    fi
done

# Check 7: Sample schemas (SH, HR)
echo
echo "[7/8] Checking sample schemas..."
for schema in "SH" "HR"; do
    printf "  %-10s: " "$schema"
    SCHEMA_STATUS=$(sudo docker exec $CONTAINER_NAME bash -c "cat <<EOF | sqlplus -s / as sysdba
SET HEADING OFF FEEDBACK OFF PAGESIZE 0
ALTER SESSION SET CONTAINER=XEPDB1;
SELECT account_status FROM dba_users WHERE username='$schema';
EXIT;
EOF" | grep -v "Session altered" | tr -d ' \n\r')

    if [ "$SCHEMA_STATUS" = "OPEN" ]; then
        echo "✓ OPEN"
    elif [ "$SCHEMA_STATUS" = "LOCKED" ]; then
        echo "⚠ LOCKED (unlock with: ALTER USER $schema ACCOUNT UNLOCK;)"
    elif [ -z "$SCHEMA_STATUS" ]; then
        echo "⚠ NOT FOUND (may need to install Oracle sample schemas)"
    else
        echo "⚠ $SCHEMA_STATUS"
    fi
done

# Check 8: All open users
echo
echo "[8/8] All users with OPEN status:"
echo
sudo docker exec $CONTAINER_NAME bash -c "cat <<EOF | sqlplus -s / as sysdba
ALTER SESSION SET CONTAINER=XEPDB1;
SET LINESIZE 120
COLUMN username FORMAT A30
COLUMN account_status FORMAT A20
COLUMN created FORMAT A20

SELECT username, account_status, TO_CHAR(created, 'YYYY-MM-DD HH24:MI') as created
FROM dba_users
WHERE account_status = 'OPEN'
AND username NOT IN ('SYS','SYSTEM','DBSNMP','XS\\\$NULL','GSMCATUSER','OUTLN','APPQOSSYS')
ORDER BY username;

EXIT;
EOF"

# Check 9: Workshop files in container
echo
echo "[9/9] Checking workshop files in container..."
WORKSHOP_DIR="/tmp/oracle-workshop"
if sudo docker exec $CONTAINER_NAME test -d "$WORKSHOP_DIR/solutions"; then
    echo "✓ Workshop files are copied to container at $WORKSHOP_DIR"
    echo
    echo "  Available solution directories:"
    sudo docker exec $CONTAINER_NAME find $WORKSHOP_DIR/solutions -maxdepth 1 -type d | tail -n +2 | sed 's|.*/||' | sed 's/^/    - /'
else
    echo "⚠ Workshop files not found in container"
    echo "  Run ./setup-docker.sh to copy files and create users"
fi

# Summary
echo
echo "========================================="
echo "Setup Check Complete"
echo "========================================="
echo
echo "Connection details:"
echo "  Host:         localhost"
echo "  Port:         1521"
echo "  Service:      XEPDB1 (recommended) or XE"
echo "  Users:        spm/spm, hr/hr, ep/ep, etc."
echo
echo "Quick connect examples:"
echo "  SQL*Plus:     sudo docker exec -it oracle21c sqlplus spm/spm@//localhost:1521/XEPDB1"
echo "  SQL Developer: localhost:1521/XEPDB1 with any workshop user"
echo
echo "To re-run setup:  ./setup-docker.sh"
echo "========================================="
