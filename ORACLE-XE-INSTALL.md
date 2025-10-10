# Oracle Database 21c Express Edition (XE) Installation Guide

This guide documents the installation of Oracle Database 21c Express Edition using Docker.

## Prerequisites

- Docker installed and running
- Sufficient disk space (minimum 10GB recommended)
- Sudo privileges (or user added to docker group)

## Installation Steps

### 1. Verify Docker Installation

Check that Docker is installed and accessible:

```bash
docker --version
```

If you get a permission error, you'll need to use `sudo` for Docker commands or add your user to the docker group:

```bash
# Option 1: Use sudo with docker commands
sudo docker ps

# Option 2: Add user to docker group (requires logout/login)
sudo usermod -aG docker $USER
```

### 2. Pull the Oracle 21c XE Docker Image

Download the official Oracle Database 21c XE image from Oracle Container Registry:

```bash
sudo docker pull container-registry.oracle.com/database/express:21.3.0-xe
```

This download is approximately 2GB and may take several minutes depending on your internet connection.

### 3. Create and Start the Oracle Container

Run the following command to create and start the Oracle database container:

```bash
sudo docker run -d \
  --name oracle21c \
  -p 1521:1521 \
  -p 5500:5500 \
  -e ORACLE_PWD=Oracle123 \
  -e ORACLE_CHARACTERSET=AL32UTF8 \
  -v oracle-data:/opt/oracle/oradata \
  container-registry.oracle.com/database/express:21.3.0-xe
```

**Parameters explained:**
- `-d`: Run container in detached mode (background)
- `--name oracle21c`: Name the container "oracle21c"
- `-p 1521:1521`: Expose Oracle listener port
- `-p 5500:5500`: Expose Oracle Enterprise Manager Express port
- `-e ORACLE_PWD=Oracle123`: Set SYS, SYSTEM, and PDBADMIN passwords
- `-e ORACLE_CHARACTERSET=AL32UTF8`: Set database character set
- `-v oracle-data:/opt/oracle/oradata`: Create persistent volume for database files

**Important:** Change `Oracle123` to a secure password in production environments!

### 4. Monitor the Database Initialization

The database initialization takes approximately 2-5 minutes. Monitor the progress:

```bash
sudo docker logs -f oracle21c
```

Watch for the message:
```
#########################
DATABASE IS READY TO USE!
#########################
```

Press `Ctrl+C` to exit the log viewer.

### 5. Verify the Installation

Check the container status:

```bash
sudo docker ps | grep oracle21c
```

Verify SQL*Plus is available:

```bash
sudo docker exec oracle21c sqlplus -v
```

Test database connectivity:

```bash
sudo docker exec oracle21c bash -c "echo 'SELECT banner FROM v\$version;' | sqlplus -s / as sysdba"
```

Check pluggable database status:

```bash
sudo docker exec oracle21c bash -c "echo 'SELECT name, open_mode FROM v\$pdbs;' | sqlplus -s / as sysdba"
```

Expected output should show:
- `XEPDB1` in `READ WRITE` mode
- `PDB$SEED` in `READ ONLY` mode

## Database Connection Information

### Container Database (CDB)

- **Service Name:** `XE`
- **Host:** `localhost`
- **Port:** `1521`
- **SYS/SYSTEM Password:** `Oracle123` (or your custom password)

**Connection string:**
```bash
sqlplus sys/Oracle123@//localhost:1521/XE as sysdba
sqlplus system/Oracle123@//localhost:1521/XE
```

### Pluggable Database (PDB)

- **Service Name:** `XEPDB1`
- **Host:** `localhost`
- **Port:** `1521`
- **PDBADMIN Password:** `Oracle123` (or your custom password)

**Connection string:**
```bash
sqlplus pdbadmin/Oracle123@//localhost:1521/XEPDB1
```

### Enterprise Manager Express

Access the web interface at:
```
https://localhost:5500/em
```

**Note:** You may need to accept a self-signed certificate warning.

## Managing the Container

### Start the Container

```bash
sudo docker start oracle21c
```

### Stop the Container

```bash
sudo docker stop oracle21c
```

### View Container Logs

```bash
sudo docker logs oracle21c
```

### Access Container Shell

```bash
sudo docker exec -it oracle21c bash
```

### Connect to SQL*Plus Inside Container

```bash
# As SYS user
sudo docker exec -it oracle21c sqlplus / as sysdba

# As SYSTEM user
sudo docker exec -it oracle21c sqlplus system/Oracle123@//localhost:1521/XE

# Connect to PDB
sudo docker exec -it oracle21c sqlplus pdbadmin/Oracle123@//localhost:1521/XEPDB1
```

## Common Tasks

### Create a New User in XEPDB1

```bash
sudo docker exec -it oracle21c sqlplus sys/Oracle123@//localhost:1521/XEPDB1 as sysdba
```

Then in SQL*Plus:

```sql
-- Create user
CREATE USER myuser IDENTIFIED BY mypassword;

-- Grant privileges
GRANT CONNECT, RESOURCE TO myuser;
GRANT UNLIMITED TABLESPACE TO myuser;

-- Exit
EXIT;
```

### Install Sample Schemas and Workshop Environment (Automated)

This repository includes an automated setup script that installs all necessary sample schemas (SH, HR) and creates all workshop users with their required tables. The script:

- Installs Java 11 and Oracle SQLcl in the container (required for CSV data loading)
- Creates all workshop users (EP, ACS, CS, TRACE, SPM, AST)
- Installs and populates Oracle sample schemas (HR, SH)
- Creates and populates workshop-specific tables with test data
- Completes in approximately 5-6 minutes

**Run the automated setup:**

```bash
cd setup
./setup-docker.sh
```

The script will:
1. Install Java 11 in the container (~30 seconds)
2. Download and install Oracle SQLcl 25.3 (~10 seconds)
3. Create 8 workshop users with proper permissions
4. Install HR schema (7 tables, 107 rows)
5. Install SH schema (9 tables, 918,843 rows loaded via SQLcl)
6. Create workshop-specific tables:
   - EP.TEST (20,000 rows)
   - ACS.EMP (100,000 rows)
   - CS.EMP (100,000 rows)
   - TRACE.SALES, SALES2, SALES3 (115,000 total rows)

**Verify the installation:**

```bash
# Check all users were created
sudo docker exec oracle21c bash -c "
echo \"SELECT username, account_status FROM dba_users
WHERE username IN ('EP','ACS','CS','TRACE','SPM','AST','HR','SH')
ORDER BY username;\" | sqlplus -s sys/Oracle123@//localhost:1521/XEPDB1 as sysdba"

# Verify table row counts
sudo docker exec oracle21c bash -c "
echo \"SELECT 'SH SALES: ' || COUNT(*) || ' rows' FROM sh.sales;
SELECT 'HR EMPLOYEES: ' || COUNT(*) || ' rows' FROM hr.employees;\" |
sqlplus -s sys/Oracle123@//localhost:1521/XEPDB1 as sysdba"
```

Expected results:
- All 8 users with OPEN status
- SH.SALES: 918,843 rows
- HR.EMPLOYEES: 107 rows
- Total data: 1,292,065 rows across all tables

**Manual installation (alternative):**

If you prefer to install sample schemas manually:

```bash
# Clone the sample schemas repository
git clone https://github.com/oracle-samples/db-sample-schemas.git

# Copy into the container and install (instructions vary by schema)
```

**Note:** The automated setup script (`setup-docker.sh`) is the recommended approach as it handles all dependencies, common issues, and verifies the installation automatically.

### Backup and Restore

The database files are stored in the `oracle-data` Docker volume, which persists even if the container is removed.

**View volume:**
```bash
sudo docker volume inspect oracle-data
```

**Backup the volume:**
```bash
sudo docker run --rm -v oracle-data:/data -v $(pwd):/backup ubuntu tar czf /backup/oracle-data-backup.tar.gz /data
```

**Restore the volume:**
```bash
sudo docker run --rm -v oracle-data:/data -v $(pwd):/backup ubuntu tar xzf /backup/oracle-data-backup.tar.gz -C /
```

## Troubleshooting

### Container Won't Start

Check the logs:
```bash
sudo docker logs oracle21c
```

### Cannot Connect to Database

1. Verify container is running: `sudo docker ps`
2. Check listener status inside container:
   ```bash
   sudo docker exec oracle21c lsnrctl status
   ```
3. Verify port is accessible: `netstat -tuln | grep 1521`

### Database Performance Issues

The Express Edition has the following limitations:
- Maximum 2 CPUs
- Maximum 2GB RAM
- Maximum 12GB user data

For better performance, allocate more resources to Docker.

### Reset/Remove Everything

```bash
# Stop and remove container
sudo docker stop oracle21c
sudo docker rm oracle21c

# Remove volume (WARNING: This deletes all data!)
sudo docker volume rm oracle-data

# Remove image
sudo docker rmi container-registry.oracle.com/database/express:21.3.0-xe
```

## Integration with This Repository

This Oracle installation is ready for use with the SQL tuning exercises in this repository. To use it:

1. Connect to the XEPDB1 pluggable database (recommended for application schemas)
2. Create the necessary users (SH, HR, SPM, ACS, etc.) as documented in CLAUDE.md
3. Run the setup scripts from the `setup/` directory

Example:
```bash
# Copy setup script into container
sudo docker cp setup/setup.sh oracle21c:/tmp/

# Execute setup
sudo docker exec -it oracle21c bash
cd /tmp
./setup.sh
```

## Installing GUI Clients

While SQL*Plus is available in the Docker container, you may want a graphical interface for easier database management.

### Option 1: Oracle SQL Developer (Official)

Oracle SQL Developer is the official free graphical tool for Oracle databases.

#### Prerequisites

Install Java 11 (if not already installed):

```bash
sudo apt-get update
sudo apt-get install -y openjdk-11-jdk
```

Verify installation:

```bash
java -version
```

#### Installation Methods

**Method A: Manual Download (Recommended)**

1. Visit the [Oracle SQL Developer Downloads page](https://www.oracle.com/database/sqldeveloper/technologies/download/)
2. Accept the Oracle Technology Network License Agreement
3. Download **"SQL Developer for Other Platforms"** (without JRE)
4. Extract the archive:

```bash
cd ~/Downloads
unzip sqldeveloper-*-no-jre.zip
sudo mv sqldeveloper /opt/
```

5. Make it executable and create a launcher:

```bash
sudo chmod +x /opt/sqldeveloper/sqldeveloper.sh

# Create wrapper script for command-line access
sudo tee /usr/local/bin/sqldeveloper > /dev/null <<'WRAPPER'
#!/bin/bash
cd /opt/sqldeveloper && ./sqldeveloper.sh "$@"
WRAPPER
sudo chmod +x /usr/local/bin/sqldeveloper

# Create desktop entry
sudo tee /usr/share/applications/sqldeveloper.desktop > /dev/null <<'EOF'
[Desktop Entry]
Name=Oracle SQL Developer
Comment=Oracle SQL Developer Database IDE
Exec=/opt/sqldeveloper/sqldeveloper.sh
Icon=/opt/sqldeveloper/icon.png
Terminal=false
Type=Application
Categories=Development;IDE;Database;
StartupWMClass=Oracle SQL Developer
EOF
```

6. Launch SQL Developer:

```bash
sqldeveloper
```

Or search for "Oracle SQL Developer" in your applications menu.

**Method B: Using the Installation Script**

This repository includes a helper script:

```bash
cd tools
./install-sqldeveloper.sh
```

Follow the prompts to download and install SQL Developer.

#### First Launch Configuration

On first launch, SQL Developer will ask you to configure:

1. **Specify Java JDK Location:** Select `/usr/lib/jvm/java-11-openjdk-amd64`
2. **Import Preferences:** Choose "No" unless migrating from a previous installation

#### Creating a Connection in SQL Developer

1. Click the **"+"** button or right-click **"Connections"** → **"New Connection"**
2. Enter connection details:

**For CDB (XE):**
- **Connection Name:** `Oracle21c-XE`
- **Username:** `system`
- **Password:** `Oracle123`
- **Connection Type:** `Basic`
- **Hostname:** `localhost`
- **Port:** `1521`
- **Service name:** `XE`

**For PDB (XEPDB1) - Recommended:**
- **Connection Name:** `Oracle21c-XEPDB1`
- **Username:** `pdbadmin`
- **Password:** `Oracle123`
- **Connection Type:** `Basic`
- **Hostname:** `localhost`
- **Port:** `1521`
- **Service name:** `XEPDB1`

3. Click **"Test"** to verify the connection
4. If successful, click **"Connect"** or **"Save"**

### Option 2: DBeaver Community (Open Source Alternative)

DBeaver is a free, open-source universal database tool that works well with Oracle.

#### Installation

```bash
# Add DBeaver repository
sudo add-apt-repository ppa:serge-rider/dbeaver-ce
sudo apt-get update

# Install DBeaver
sudo apt-get install -y dbeaver-ce
```

Or download from [dbeaver.io](https://dbeaver.io/download/)

#### Launch DBeaver

```bash
dbeaver
```

Or search for "DBeaver" in your applications menu.

#### Creating a Connection in DBeaver

1. Click **"New Database Connection"** or press `Ctrl+Shift+N`
2. Select **"Oracle"** and click **"Next"**
3. On first use, DBeaver will offer to download Oracle JDBC drivers - click **"Download"**
4. Enter connection details (same as SQL Developer above)
5. Click **"Test Connection"** to verify
6. Click **"Finish"** to save

### Option 3: Command-Line SQL*Plus from Host

Install Oracle Instant Client to use SQL*Plus directly from your host machine:

```bash
# Install dependencies
sudo apt-get install -y alien libaio1

# Download Oracle Instant Client from Oracle website
# Then install the RPM packages:
sudo alien -i oracle-instantclient-basic-*.rpm
sudo alien -i oracle-instantclient-sqlplus-*.rpm

# Set environment variables
export PATH=$PATH:/usr/lib/oracle/21/client64/bin
export LD_LIBRARY_PATH=/usr/lib/oracle/21/client64/lib

# Add to ~/.bashrc for persistence
echo 'export PATH=$PATH:/usr/lib/oracle/21/client64/bin' >> ~/.bashrc
echo 'export LD_LIBRARY_PATH=/usr/lib/oracle/21/client64/lib' >> ~/.bashrc
```

Connect to the database:

```bash
sqlplus system/Oracle123@//localhost:1521/XE
```

## Working with SQL Scripts from This Repository

Once you have a GUI client installed, you can easily execute the workshop scripts:

### Using SQL Developer

1. Open a connection to XEPDB1
2. Click **File** → **Open** and navigate to a script (e.g., `workshops/ws01.sql`)
3. Press **F5** to run as script or **F9** to run statement under cursor
4. View results in the bottom panel

### Using DBeaver

1. Open a connection to XEPDB1
2. Click **SQL Editor** → **New SQL Script**
3. Open a file using **File** → **Open File**
4. Press **Ctrl+Enter** to execute the script
5. View results in the results panel

### Tips for Workshop Exercises

1. **Always run setup scripts first:** Most workshops have `setupNN.sql` files
2. **Use the PDB (XEPDB1):** The pluggable database is recommended for application schemas
3. **Check the CLAUDE.md file:** Contains useful patterns and workflow guidance
4. **Run cleanup scripts after:** Use `cleanupNN.sql` to reset the environment

## Resources

- [Oracle Database Express Edition Documentation](https://docs.oracle.com/en/database/oracle/oracle-database/21/xeinl/)
- [Oracle Container Registry](https://container-registry.oracle.com/)
- [Oracle Database Docker Images GitHub](https://github.com/oracle/docker-images)
- [Oracle SQL Developer Documentation](https://docs.oracle.com/en/database/oracle/sql-developer/)
- [DBeaver Documentation](https://dbeaver.com/docs/)

## Version Information

- **Oracle Database:** 21c Express Edition Release 21.0.0.0.0 - Production
- **SQL*Plus:** Release 21.0.0.0.0 - Production
- **Image Tag:** `21.3.0-xe`
- **Installation Date:** 2025-10-10
- **Recommended GUI:** Oracle SQL Developer 24.3 or DBeaver Community 24.x
