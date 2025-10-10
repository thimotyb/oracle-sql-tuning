# Oracle SQL Performance Tuning Workshop

This repository contains hands-on workshop exercises, solutions, demonstrations, and code examples for Oracle Database performance optimization techniques.

## Quick Start

### 1. Install Oracle Database 21c XE (Docker)

See [ORACLE-XE-INSTALL.md](ORACLE-XE-INSTALL.md) for complete installation instructions.

**Quick install:**

```bash
# Pull the Oracle 21c XE Docker image
sudo docker pull container-registry.oracle.com/database/express:21.3.0-xe

# Create and start the container
sudo docker run -d \
  --name oracle21c \
  -p 1521:1521 \
  -p 5500:5500 \
  -e ORACLE_PWD=Oracle123 \
  -e ORACLE_CHARACTERSET=AL32UTF8 \
  -v oracle-data:/opt/oracle/oradata \
  container-registry.oracle.com/database/express:21.3.0-xe

# Wait for database to initialize (2-5 minutes)
sudo docker logs -f oracle21c
# Watch for: "DATABASE IS READY TO USE!"
```

### 2. Set Up Workshop Schemas

Run the Docker-compatible setup script to create all required users and schemas:

```bash
cd setup
./setup-docker.sh
```

This script will:
- Copy workshop files into the Oracle container
- Create all required database users and schemas
- Set up sample data and tables for the exercises

**Users created:**

| Username | Password | Purpose | Tables Created | Status |
|----------|----------|---------|----------------|--------|
| **SPM** | spm | SQL Performance Management | - | ✓ Ready |
| **EP** | ep | Explain Plan practice | TEST (20K rows) | ✓ Ready |
| **TRACE** | trace | Application Tracing practice | SALES, SALES2, SALES3 | ✓ Ready |
| **ACS** | acs | Adaptive Cursor Sharing | EMP (100K rows) | ✓ Ready |
| **CS** | cs | Cursor Sharing techniques | EMP (100K rows) | ✓ Ready |
| **AST** | ast | Automatic Statistics Tuning | - | ✓ Ready |
| **AGS** | ags | Automatic Gather Stats | - | ✓ Ready |
| **HR** | hr | Human Resources sample schema | 7 tables (107 employees) | ✓ Ready |
| **SH** | sh | Sales History sample schema | 9 tables (918K sales records) | ✓ Ready |
| **QRC** | qrc | Query Result Cache practice | - | ⚠ Optional* |
| **SHC** | shc | Access Paths - SHC user | - | ⚠ Optional* |
| **NIC** | nic | Access Paths - NIC user | - | ⚠ Optional* |
| **IC** | ic | Access Paths - IC user | - | ⚠ Optional* |

**Note:** All users have passwords matching their usernames (e.g., `spm/spm`, `ep/ep`).

\* *Optional users may have setup script dependencies that need to be resolved.*

**All core workshop users and tables are created automatically by `setup-docker.sh`**, including:
- **EP**: TEST table with 20,000 rows and indexes
- **ACS/CS**: EMP tables with 100,000 rows each
- **TRACE**: SALES, SALES2, SALES3 tables (sourced from SH.SALES)
- **HR**: 7 tables with sample data (regions, countries, departments, locations, employees, jobs, job_history)
- **SH**: 9 tables with full sample data (918K sales, 55K customers, 82K costs, etc.)

The setup script automatically handles all dependencies and creates tables in the correct order (e.g., TRACE tables are created after SH is populated).

To verify the setup and check table counts:
```bash
cd setup
./check-setup-docker.sh
```

### 3. Install a GUI Client (Optional)

See [ORACLE-XE-INSTALL.md](ORACLE-XE-INSTALL.md#installing-gui-clients) for detailed instructions.

**Option 1: Oracle SQL Developer (Official)**

1. Download from [Oracle's website](https://www.oracle.com/database/sqldeveloper/technologies/download/)
2. Extract and install:
   ```bash
   cd ~/Downloads
   unzip sqldeveloper-*-no-jre.zip
   sudo mv sqldeveloper /opt/
   ```
3. Use the helper script:
   ```bash
   cd tools
   ./install-sqldeveloper.sh
   ```

**Option 2: DBeaver (Open Source)**

```bash
sudo add-apt-repository ppa:serge-rider/dbeaver-ce
sudo apt-get update
sudo apt-get install -y dbeaver-ce
```

### 4. Connect to the Database

**Connection Details:**
- **Host:** localhost
- **Port:** 1521
- **Service Name:** XEPDB1 (recommended) or XE
- **Username/Password:** Any of the users created above (e.g., spm/spm)

**Via SQL*Plus (inside container):**
```bash
sudo docker exec -it oracle21c sqlplus spm/spm@//localhost:1521/XEPDB1
```

**Via SQL Developer or DBeaver:**
- Create a new connection using the details above
- Test the connection
- Start running workshop scripts!

## Repository Structure

```
.
├── workshops/          # Workshop exercise files
│   ├── ws01.sql
│   ├── ws05.sql
│   ├── setup01.sql    # Setup scripts for workshops
│   └── cleanup01.sql  # Cleanup scripts
│
├── solutions/          # Complete solutions organized by topic
│   ├── SPM/                          # SQL Plan Management
│   ├── Access_Paths/                 # Index optimization
│   ├── Adaptive_Cursor_Sharing/      # ACS features
│   ├── Cursor_Sharing/               # Cursor sharing
│   ├── Query_Result_Cache/           # Result cache
│   ├── Explain_Plan/                 # Execution plans
│   ├── Application_Tracing/          # SQL tracing
│   └── Common_Mistakes/              # Anti-patterns
│
├── demo/               # Instructor demonstrations
├── code_ex/            # Code examples
├── setup/              # Environment setup scripts
│   ├── setup-docker.sh # Docker-compatible setup (USE THIS)
│   └── setup.sh        # Original setup (for traditional installs)
│
└── tools/              # Helper utilities
    └── install-sqldeveloper.sh
```

## Working with Workshops

### Basic Workflow

1. **Run setup script** (if required):
   ```bash
   cd workshops
   sqlplus user/pass @setupNN.sql
   ```

2. **Execute workshop**:
   ```bash
   sqlplus user/pass @wsNN.sql
   ```

3. **Run cleanup** (optional):
   ```bash
   sqlplus user/pass @cleanupNN.sql
   ```

### Using SQL Developer

1. Open connection to XEPDB1
2. File → Open → Navigate to workshop script
3. Press **F5** to run as script or **F9** to run current statement
4. View results in the bottom panel

### Using DBeaver

1. Open connection to XEPDB1
2. SQL Editor → New SQL Script
3. File → Open File → Select workshop script
4. Press **Ctrl+Enter** to execute
5. View results in the results panel

## Key Topics Covered

### SQL Performance Management (SPM)
- Creating SQL Tuning Sets (STS)
- Loading and managing baselines
- Plan evolution and tuning
- Files: `solutions/SPM/`

### Access Path Optimization
- Index creation and management
- Bitmap indexes, IOT, invisible indexes
- Index monitoring and statistics
- Files: `solutions/Access_Paths/`

### Execution Plan Analysis
- EXPLAIN PLAN methods
- DBMS_XPLAN usage
- Real-Time SQL Monitoring
- AWR-based plan retrieval
- Files: `solutions/Explain_Plan/`

### Adaptive Cursor Sharing (ACS)
- Bind variable optimization
- Cursor sharing techniques
- Files: `solutions/Adaptive_Cursor_Sharing/`, `solutions/Cursor_Sharing/`

### Statistics Management
- Pending statistics testing
- Automatic statistics gathering
- System statistics configuration
- Files: `solutions/Pending_Optimizer_Stats/`, `solutions/Automatic_Gather_Stats/`

### Application Tracing
- SQL tracing and diagnostics
- Performance analysis
- Files: `solutions/Application_Tracing/`

## Naming Conventions

- `setupNN.sql` / `cleanupNN.sql` - Workshop setup/teardown
- `wN_sN_a.sql` - Workshop N, Section N, step A
- `query{N}.sql` - Test queries
- `explain_query{N}.sql` - Execution plan analysis
- `demo_XX_YY_ZZ.sql` - Chapter XX, Section YY, Example ZZ

## Common Commands

### Container Management

```bash
# Start container
sudo docker start oracle21c

# Stop container
sudo docker stop oracle21c

# View logs
sudo docker logs oracle21c

# Access container shell
sudo docker exec -it oracle21c bash

# Connect to SQL*Plus
sudo docker exec -it oracle21c sqlplus / as sysdba
```

### Database Operations

```bash
# Check database status
sudo docker exec oracle21c sqlplus -s / as sysdba <<EOF
SELECT instance_name, status FROM v\$instance;
SELECT name, open_mode FROM v\$pdbs;
EXIT;
EOF

# Gather statistics for a table
sqlplus / as sysdba
SQL> exec dbms_stats.gather_table_stats('SCHEMA','TABLE');

# View execution plan
SQL> SET AUTOTRACE TRACEONLY EXPLAIN
SQL> SELECT * FROM table WHERE condition;
```

## Troubleshooting

### Container won't start
```bash
sudo docker logs oracle21c
```

### Can't connect to database
```bash
# Check container status
sudo docker ps

# Check listener
sudo docker exec oracle21c lsnrctl status

# Verify port
netstat -tuln | grep 1521
```

### Setup script errors
Make sure you're using the Docker-compatible setup script:
```bash
cd setup
./setup-docker.sh  # NOT setup.sh
```

The original `setup.sh` is designed for traditional Oracle installations with paths like `/home/oracle/`. Use `setup-docker.sh` for Docker environments.

### SQL*Plus not found on host
SQL*Plus is only available inside the container. Either:
- Run commands inside the container: `sudo docker exec -it oracle21c sqlplus ...`
- Use a GUI client (SQL Developer or DBeaver)
- Install Oracle Instant Client on host (see ORACLE-XE-INSTALL.md)

## Documentation

- **[ORACLE-XE-INSTALL.md](ORACLE-XE-INSTALL.md)** - Complete installation guide
  - Docker-based Oracle 21c XE setup
  - GUI client installation (SQL Developer, DBeaver)
  - Connection configuration
  - Troubleshooting guide

- **[CLAUDE.md](CLAUDE.md)** - Developer guidelines
  - Project architecture and patterns
  - Coding conventions
  - File organization
  - Workflow best practices

## Resources

- [Oracle Database 21c XE Documentation](https://docs.oracle.com/en/database/oracle/oracle-database/21/xeinl/)
- [Oracle SQL Developer](https://www.oracle.com/database/sqldeveloper/)
- [DBeaver Community Edition](https://dbeaver.io/)
- [Oracle Performance Tuning Guide](https://docs.oracle.com/en/database/oracle/oracle-database/21/tgdba/)

## System Requirements

- **Docker** with 10GB+ free space
- **Memory:** 4GB+ recommended (Docker needs 2GB+ for Oracle XE)
- **OS:** Linux, macOS, or Windows with WSL2
- **Java 11 or 17** (for SQL Developer)

## License

This is a training repository. Check with your organization regarding usage rights for Oracle Database software and sample schemas.

## Support

For issues with:
- **Oracle Database:** Check container logs and [Oracle documentation](https://docs.oracle.com/en/database/oracle/oracle-database/21/)
- **Workshop content:** Review the `solutions/` directory for working examples
- **Setup scripts:** Ensure you're using `setup-docker.sh` for Docker environments

---

**Note:** This workshop uses Oracle Database 21c Express Edition, which has the following limitations:
- Maximum 2 CPUs
- Maximum 2GB RAM
- Maximum 12GB user data

For production workloads or larger datasets, consider Oracle Database Standard or Enterprise Edition.
