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
echo "Creating database users and schemas..."
echo

# Create setup script inside container
sudo docker exec $CONTAINER_NAME bash -c "cat > $CONTAINER_WORK_DIR/run_setup.sh" <<'SETUPSCRIPT'
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
    sqlplus / as sysdba @ep_setup.sql || echo "WARNING: EP setup failed"
    cd $WORK_DIR
else
    echo "SKIP: Explain Plan setup files not found"
fi

echo
echo "=== Setting up Application Tracing (TRACE) schema ==="
if [ -f "solutions/Application_Tracing/at_setup.sql" ]; then
    cd solutions/Application_Tracing
    sqlplus / as sysdba @at_setup.sql || echo "WARNING: Application Tracing setup failed"
    cd $WORK_DIR
else
    echo "SKIP: Application Tracing setup files not found"
fi

echo
echo "=== Setting up Access Paths ==="
if [ -d "solutions/Access_Paths" ]; then
    cd solutions/Access_Paths

    if [ -f "ap_setup.sql" ]; then
        sqlplus / as sysdba @ap_setup.sql || echo "WARNING: ap_setup failed"
    fi

    if [ -f "idx_setup.sql" ]; then
        sqlplus sh/sh @idx_setup.sql || echo "WARNING: idx_setup failed"
    fi

    if [ -f "create_mysales_index.sql" ]; then
        sqlplus sh/sh @create_mysales_index.sql || echo "WARNING: create_mysales_index failed"
    fi

    cd $WORK_DIR
else
    echo "SKIP: Access Paths setup files not found"
fi

echo
echo "=== Creating SPM user ==="
sqlplus /nolog <<EOF
connect / as sysdba
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
    sqlplus / as sysdba @acs_setup.sql || echo "WARNING: ACS setup failed"
    cd $WORK_DIR
else
    echo "SKIP: ACS setup files not found"
fi

echo
echo "=== Setting up Cursor Sharing (CS) schema ==="
if [ -f "solutions/Cursor_Sharing/cs_setup.sql" ]; then
    cd solutions/Cursor_Sharing
    sqlplus / as sysdba @cs_setup.sql || echo "WARNING: CS setup failed"
    cd $WORK_DIR
else
    echo "SKIP: CS setup files not found"
fi

echo
echo "=== Creating AST user ==="
sqlplus / as sysdba <<EOF
drop user ast cascade;
create user ast identified by ast;
grant dba to ast;
exit
EOF

echo
echo "=== Setting up Hints/IOT schema ==="
if [ -f "solutions/Hints/iot_setup.sql" ]; then
    cd solutions/Hints
    sqlplus / as sysdba @iot_setup.sql || echo "WARNING: IOT setup failed"
    cd $WORK_DIR
else
    echo "SKIP: Hints/IOT setup files not found"
fi

echo
echo "=== Unlocking HR account ==="
sqlplus / as sysdba <<EOF
alter user hr identified by hr account unlock;
grant dba to hr;
grant select_catalog_role to hr;
grant select any dictionary to hr;
exit
EOF

echo
echo "=== Granting ALTER SESSION to PUBLIC ==="
sqlplus / as sysdba <<EOF
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
    sqlplus / as sysdba @sysstats_setup.sql || echo "WARNING: System Stats setup failed"
    cd $WORK_DIR
else
    echo "SKIP: System Stats setup files not found"
fi

echo
echo "=== Setting up Automatic Gather Stats ==="
if [ -f "solutions/Automatic_Gather_Stats/ags_setup.sql" ]; then
    cd solutions/Automatic_Gather_Stats
    sqlplus / as sysdba @ags_setup.sql || echo "WARNING: AGS setup failed"
    cd $WORK_DIR
else
    echo "SKIP: AGS setup files not found"
fi

echo
echo "========================================="
echo "Setup Complete!"
echo "========================================="
SETUPSCRIPT

# Make the script executable and run it
sudo docker exec $CONTAINER_NAME chmod +x $CONTAINER_WORK_DIR/run_setup.sh
echo
echo "Running setup inside container..."
echo
sudo docker exec -it $CONTAINER_NAME bash -c "cd $CONTAINER_WORK_DIR && ./run_setup.sh"

echo
echo "========================================="
echo "Workshop Setup Complete!"
echo "========================================="
echo
echo "Created users and schemas:"
echo "  - SPM (SQL Performance Management)"
echo "  - EP (Explain Plan)"
echo "  - TRACE (Application Tracing)"
echo "  - ACS (Adaptive Cursor Sharing)"
echo "  - CS (Cursor Sharing)"
echo "  - AST (Automatic Statistics Tuning)"
echo "  - HR (unlocked and configured)"
echo "  - SHC, NIC, IC (Access Paths users)"
echo "  - QRC (Query Result Cache)"
echo
echo "All users have password same as username (e.g., spm/spm)"
echo
echo "Workshop files are available in container at:"
echo "  $CONTAINER_WORK_DIR"
echo
