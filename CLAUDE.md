# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is an Oracle SQL Performance Tuning training repository containing workshop exercises, solutions, demonstrations, and code examples. The repository is designed for hands-on practice with Oracle Database performance optimization techniques.

## Repository Structure

- **`workshops/`**: Workshop exercise files (ws01.sql, ws05.sql, etc.)
  - Setup scripts: `setup01.sql`, `setup09.sql`, etc.
  - Cleanup scripts: `cleanup01.sql`, `cleanup02.sql`, etc.
  - Exercise files: `w2_s2_b.sql`, `w5_s4_a.sql`, etc. (pattern: `w{workshop}_s{section}_{step}.sql`)

- **`solutions/`**: Complete solutions organized by topic:
  - `SPM/` - SQL Plan Management
  - `Access_Paths/` - Index optimization and access path selection
  - `Adaptive_Cursor_Sharing/` - ACS features and bind variable optimization
  - `Cursor_Sharing/` - Cursor sharing techniques
  - `Query_Result_Cache/` - Result cache configuration
  - `Pending_Optimizer_Stats/` - Statistics management
  - `Automatic_Gather_Stats/` - Auto statistics gathering
  - `System_Stats/` - System statistics configuration
  - `Common_Mistakes/` - Anti-patterns and common errors
  - `Explain_Plan/` - Execution plan analysis
  - `Application_Tracing/` - SQL tracing and diagnostics
  - `SQL_Access_Advisor/` - Advisor recommendations
  - `Trace_Event/` - Event tracing

- **`demo/`**: Instructor demonstrations (demo_04_01_01.sql, etc.)

- **`code_ex/`**: Code examples referenced in training materials

- **`setup/`**: Environment setup scripts
  - `setup.sh` - Master setup script
  - `check_setup.sh` - Validation script

## Common Commands

### Running SQL Scripts

Connect to Oracle Database and execute scripts using SQL*Plus:

```bash
# Connect as sysdba
sqlplus / as sysdba @path/to/script.sql

# Connect as specific user
sqlplus username/password @path/to/script.sql

# Common schema users: SH, HR, SPM, ACS, CS, EP, TRACE, AST, QRC
sqlplus sh/sh @solutions/Access_Paths/idx_setup.sql
```

### Environment Setup

```bash
# Run master setup (creates users and schemas)
cd setup
./setup.sh

# Verify setup
./check_setup.sh
```

### Workshop Workflow

1. Run setup: `sqlplus user/pass @setupNN.sql`
2. Execute workshop: `sqlplus user/pass @wsNN.sql`
3. Run cleanup: `sqlplus user/pass @cleanupNN.sql`

## Key Architecture Patterns

### SQL Performance Management (SPM)

The SPM solutions demonstrate SQL plan baseline management:
- Creating SQL Tuning Sets (STS): `catchup_sts.sql`, `check_sts.sql`
- Loading baselines: `populate_baseline.sql`, `load_cc_baseline.sql`, `load_use_baseline.sql`
- Evolution: `check_evolve_plan.sql`, `tune_evolve_sql.sql`, `accept_evolve_baseline.sql`
- Purging: `purge_auto_baseline.sql`, `purge_cc_baseline.sql`

### Access Path Optimization

Solutions include various index types and access methods:
- Setup/cleanup pairs: `idx_setup.sql` / `idx_cleanup.sql`
- Index creation patterns: `create_cust_*_index.sql` (regular), `create_cust_*_bindex.sql` (bitmap)
- Special structures: `iot_setup.sql` (Index-Organized Tables), `iss_setup.sql` (Invisible Indexes)
- Monitoring: `start_monitoring_indexes.sql`

### Statistics Management

Two-phase approach for testing statistics changes:
1. Collect pending stats: `collect_pending.sql`
2. Test with pending mode: `pending_mode.sql`
3. Evaluate: `determine1.sql`, `determine2.sql`
4. Publish or delete: `publish_stats.sql` / `delete_stats.sql`

### Explain Plan Analysis

Multiple methods for retrieving execution plans:
- `ep_explain.sql` - EXPLAIN PLAN FOR
- `ep_execute.sql` - DBMS_XPLAN.DISPLAY_CURSOR
- `ep_monitor.sql` - Real-Time SQL Monitoring
- `ep_retrieve_awr.sql`, `ep_show_awr.sql` - AWR-based plans

## Schema Conventions

- **SH**: Sales History sample schema (main data source)
- **HR**: Human Resources sample schema
- **SPM**: SQL Plan Management practice user
- **ACS**: Adaptive Cursor Sharing practice user
- **CS**: Cursor Sharing practice user
- **EP**: Explain Plan practice user
- **QRC**: Query Result Cache practice user
- **AST**: Auto Statistics Tuning user

## File Naming Patterns

- `query{N}.sql` - Test queries (e.g., query1.sql, query2.sql)
- `explain_query{N}.sql` - Execution plan analysis for corresponding query
- `{feature}_setup.sql` / `{feature}_cleanup.sql` - Setup/teardown pairs
- `w{N}_s{N}_{step}.sql` - Workshop exercises (workshop, section, step)
- `demo_{chapter}_{section}_{example}.sql` - Demonstration scripts

## Working with Execution Plans

To analyze a query's execution plan:

1. Generate plan: Use `EXPLAIN PLAN FOR` or auto-trace
2. View plan: Query `PLAN_TABLE` or use `DBMS_XPLAN.DISPLAY`
3. Compare plans: Use explain_query*.sql files to see different execution strategies
4. Check statistics: Use `show_*_stats.sql` patterns

## Testing Workflow

When modifying SQL for performance:

1. Establish baseline: Run query and capture plan/timing
2. Gather statistics: `exec dbms_stats.gather_table_stats('SCHEMA','TABLE')`
3. Test change: Apply index/hint/rewrite
4. Compare plans: Use DBMS_XPLAN.DISPLAY_CURSOR
5. Cleanup: Run corresponding cleanup script

## Database Context

This repository assumes:
- Oracle Database 11g or later
- Sample schemas (SH, HR) are installed or will be created by setup scripts
- DBA privileges for setup operations
- SQL*Plus as primary interface

## Docker Setup (Oracle 21c XE)

### Container Information
- **Image**: `container-registry.oracle.com/database/express:21.3.0-xe`
- **Container Name**: `oracle21c`
- **Port Mapping**: Host 1521 → Container 1521
- **Database**: XEPDB1 (pluggable database)
- **SYS Password**: Oracle123

### Setup Process
The automated setup script (`setup/setup-docker.sh`) performs the following:

1. **Java and SQLcl Installation**
   - Installs Java 11 (required for SQLcl CSV loading)
   - Downloads and installs Oracle SQLcl 25.3
   - SQLcl is needed because SH schema uses CSV LOAD commands

2. **Workshop User Creation**
   - EP (Explain Plan) with TEST table (20,000 rows)
   - ACS (Adaptive Cursor Sharing) with EMP table (100,000 rows)
   - CS (Cursor Sharing) with EMP table (100,000 rows)
   - TRACE (Application Tracing) with SALES tables (from SH.SALES)
   - SPM (SQL Plan Management)
   - AST (Automatic Statistics Tuning)

3. **Oracle Sample Schemas**
   - HR schema (7 tables, 107 employees)
   - SH schema (9 tables, 918,843 sales records loaded via SQLcl)

### Running the Setup

```bash
# Start container
sudo docker start oracle21c

# Run automated setup (creates all users and loads data)
cd setup
./setup-docker.sh
```

Setup completes in approximately 5 minutes, with SH data loading taking ~1 minute via SQLcl.

## Common Issues and Solutions

### Issue 1: User Login Failures (ORA-01017)
**Problem**: After user creation, immediate login attempts fail with "invalid username/password"
**Root Cause**: Oracle Database takes a moment to propagate user credentials
**Solution**: Use separate sqlplus sessions - create user in one session, connect in a new session
**Workaround**: The setup script uses sqlplus without immediate connection for table creation

### Issue 2: SH Schema Empty Tables (0 rows)
**Problem**: SH tables created but `sh_populate.sql` leaves them empty when run with SQL*Plus
**Root Cause**: Oracle's `sh_populate.sql` uses SQLcl-specific `LOAD` commands that don't work in SQL*Plus:
```sql
SET LOAD BATCH_ROWS 10000 BATCHES_PER_COMMIT 1 DATE_FORMAT YYYY-MM-DD
LOAD costs costs.csv
LOAD customers customers.csv
-- etc...
```
**Solution**:
1. Install Java 11 in container (SQLcl requires Java 11+, Oracle container has Java 8)
2. Download and install SQLcl
3. Use SQLcl instead of SQL*Plus to run `sh_populate.sql`

### Issue 3: SQLcl Java Version Error
**Problem**: SQLcl reports "Error: SQLcl requires Java 11 and above to run. Found Java version 8."
**Root Cause**: Oracle 21c XE container includes Java 8 by default, SQLcl finds it first
**Solution**: Set `JAVA_HOME=/usr/lib/jvm/jre-11-openjdk` before executing SQLcl
```bash
export JAVA_HOME=/usr/lib/jvm/jre-11-openjdk
/opt/sqlcl/bin/sql sys/Oracle123@//localhost:1521/XEPDB1 as sysdba @script.sql
```

### Issue 4: Nested Heredoc Failures
**Problem**: Files created with heredoc inside heredoc don't get created properly
**Example**:
```bash
cat > /tmp/run_setup.sh <<'OUTER'
#!/bin/bash
cat > /tmp/inner.sql <<'INNER'
SELECT * FROM dual;
INNER
OUTER
```
**Root Cause**: The inner heredoc delimiter (`INNER`) must be on a line by itself with no indentation, which conflicts with the outer script's indentation
**Solution**: Create files on the host and copy them to the container instead:
```bash
# Create file on host
cat > /tmp/sample-schema-installers/load_sh_data.sql <<'SQLCL'
SET ECHO OFF
@@sh_populate.sql
EXIT
SQLCL

# Copy to container
sudo docker cp /tmp/sample-schema-installers/load_sh_data.sql $CONTAINER_NAME:/path/
```

### Issue 5: Shell Variable Escaping in Heredocs
**Problem**: Variables and command substitutions in heredocs can cause syntax errors
**Common Errors**:
```bash
# This fails with syntax error
cat > script.sh <<'HEREDOC'
export JAVA_HOME=$(ls -d /usr/lib/jvm/java-*-openjdk* | head -1)
HEREDOC
```
**Root Cause**: Even with single quotes in `<<'HEREDOC'`, backslash escaping of `$()` can create issues
**Solution**: Use literal paths or create files outside heredocs when possible

### Issue 6: Docker Exec Permission Errors
**Problem**: `yum install` fails with "You need to be root to perform this command"
**Root Cause**: Default docker exec runs as the oracle user, not root
**Solution**: Use `-u root` flag for privileged operations:
```bash
sudo docker exec -u root $CONTAINER_NAME yum install -y java-11-openjdk-headless
```

### Issue 7: XEPDB1 vs XE Database Connections
**Problem**: Some operations fail because scripts try to connect to CDB root instead of PDB
**Root Cause**: Oracle 21c XE uses pluggable database architecture
**Solution**: Always connect to XEPDB1 for workshop operations:
```bash
sqlplus sys/Oracle123@//localhost:1521/XEPDB1 as sysdba
# NOT: sqlplus / as sysdba (connects to CDB$ROOT)
```

## File Modifications Made

### setup/setup-docker.sh
Major enhancements to automate complete workshop environment setup:

1. **Added Java 11 and SQLcl installation** (lines 198-232)
   - Checks for existing Java 11+ installation
   - Installs java-11-openjdk-headless if needed
   - Downloads SQLcl 25.3 from Oracle
   - Extracts and installs SQLcl to /opt/sqlcl in container

2. **Created load_sh_data.sql on host** (lines 194-210)
   - Wrapper script for sh_populate.sql
   - Copies to container with other installation scripts
   - Avoids nested heredoc issues

3. **Integrated table creation for workshop users** (in run_setup.sh heredoc)
   - EP.TEST: 20,000 rows via PL/SQL loop
   - ACS.EMP: 100,000 rows via Cartesian join
   - CS.EMP: 100,000 rows via Cartesian join
   - TRACE.SALES tables: populated from SH.SALES after SH installation

4. **SH data loading via SQLcl** (lines 471-478)
   - Sets `JAVA_HOME=/usr/lib/jvm/jre-11-openjdk`
   - Executes load_sh_data.sql using SQLcl instead of SQL*Plus
   - Loads all CSV files (costs, customers, promotions, sales, times, etc.)

### Git History
```
8a25aa2 - Fix SQLcl data loading by creating script on host instead of in heredoc
716c1be - Fix SQLcl Java version issue by setting JAVA_HOME to Java 11
c06659a - (previous work on SQLcl integration)
def62e8 - Fix setup scripts to use XEPDB1 pluggable database
```

## Verification Commands

After setup completes, verify the installation:

```bash
# Check all workshop users exist
sudo docker exec oracle21c sqlplus -s sys/Oracle123@//localhost:1521/XEPDB1 as sysdba <<EOF
SELECT username, account_status FROM dba_users
WHERE username IN ('EP','ACS','CS','TRACE','SPM','AST','HR','SH')
ORDER BY username;
EOF

# Verify table row counts
sudo docker exec oracle21c bash -c "
echo \"SELECT 'EP TEST: ' || COUNT(*) || ' rows' FROM ep.test;
SELECT 'ACS EMP: ' || COUNT(*) || ' rows' FROM acs.emp;
SELECT 'CS EMP: ' || COUNT(*) || ' rows' FROM cs.emp;
SELECT 'TRACE SALES: ' || COUNT(*) || ' rows' FROM trace.sales;
SELECT 'SH SALES: ' || COUNT(*) || ' rows' FROM sh.sales;
SELECT 'SH CUSTOMERS: ' || COUNT(*) || ' rows' FROM sh.customers;
SELECT 'HR EMPLOYEES: ' || COUNT(*) || ' rows' FROM hr.employees;\" |
sqlplus -s sys/Oracle123@//localhost:1521/XEPDB1 as sysdba"
```

Expected results:
- EP.TEST: 20,000 rows
- ACS.EMP: 100,000 rows
- CS.EMP: 100,000 rows
- TRACE.SALES: 100,000 rows
- SH.SALES: 918,843 rows
- SH.CUSTOMERS: 55,500 rows
- HR.EMPLOYEES: 107 rows
