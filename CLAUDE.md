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
