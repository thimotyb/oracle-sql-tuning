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

### Install Sample Schemas (SH, HR, etc.)

The sample schemas mentioned in this repository's CLAUDE.md (SH, HR) need to be installed separately. You can download them from Oracle's GitHub:

```bash
# Clone the sample schemas repository
git clone https://github.com/oracle-samples/db-sample-schemas.git

# Copy into the container and install (instructions vary by schema)
```

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

## Resources

- [Oracle Database Express Edition Documentation](https://docs.oracle.com/en/database/oracle/oracle-database/21/xeinl/)
- [Oracle Container Registry](https://container-registry.oracle.com/)
- [Oracle Database Docker Images GitHub](https://github.com/oracle/docker-images)

## Version Information

- **Oracle Database:** 21c Express Edition Release 21.0.0.0.0 - Production
- **SQL*Plus:** Release 21.0.0.0.0 - Production
- **Image Tag:** `21.3.0-xe`
- **Installation Date:** 2025-10-10
