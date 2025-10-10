#!/bin/bash
# Oracle SQL Developer Installation Script

set -e

SQLD_VERSION="24.3.0.284.2209"
SQLD_DIR="/opt/sqldeveloper"
DOWNLOAD_URL="https://download.oracle.com/otn/java/sqldeveloper/sqldeveloper-${SQLD_VERSION}-no-jre.zip"

echo "==========================================="
echo "Oracle SQL Developer Installation Script"
echo "==========================================="
echo

# Check if Java is installed
if ! command -v java &> /dev/null; then
    echo "Java is not installed. Installing OpenJDK 11..."
    sudo apt-get update
    sudo apt-get install -y openjdk-11-jdk
else
    echo "Java is already installed:"
    java -version
fi

echo
echo "==========================================="
echo "MANUAL DOWNLOAD REQUIRED"
echo "==========================================="
echo
echo "Oracle requires you to accept their license agreement before downloading."
echo "Please follow these steps:"
echo
echo "1. Visit: https://www.oracle.com/database/sqldeveloper/technologies/download/"
echo "2. Accept the Oracle Technology Network License Agreement"
echo "3. Download: 'SQL Developer for Other Platforms' (No JRE included)"
echo "4. Save the file to: /tmp/sqldeveloper.zip"
echo
echo "Alternatively, use wget/curl with cookies after logging in to Oracle:"
echo "   wget --no-cookies --no-check-certificate \\
        --header 'Cookie: oraclelicense=accept-securebackup-cookie' \\
        '${DOWNLOAD_URL}' \\
        -O /tmp/sqldeveloper.zip"
echo
read -p "Press Enter after you have downloaded the file to /tmp/sqldeveloper.zip..."

# Check if file exists
if [ ! -f "/tmp/sqldeveloper.zip" ]; then
    echo "ERROR: File not found at /tmp/sqldeveloper.zip"
    echo "Please download the file and try again."
    exit 1
fi

# Extract SQL Developer
echo
echo "Extracting SQL Developer..."
sudo unzip -q /tmp/sqldeveloper.zip -d /opt/

# Set permissions
echo "Setting permissions..."
sudo chmod +x ${SQLD_DIR}/sqldeveloper.sh

# Create desktop entry
echo "Creating desktop launcher..."
sudo tee /usr/share/applications/sqldeveloper.desktop > /dev/null <<EOF
[Desktop Entry]
Name=Oracle SQL Developer
Comment=Oracle SQL Developer Database IDE
Exec=${SQLD_DIR}/sqldeveloper.sh
Icon=${SQLD_DIR}/icon.png
Terminal=false
Type=Application
Categories=Development;IDE;Database;
StartupWMClass=Oracle SQL Developer
EOF

# Create wrapper script
echo "Creating command-line wrapper..."
sudo tee /usr/local/bin/sqldeveloper > /dev/null <<'WRAPPER'
#!/bin/bash
cd /opt/sqldeveloper && ./sqldeveloper.sh "$@"
WRAPPER
sudo chmod +x /usr/local/bin/sqldeveloper

echo
echo "==========================================="
echo "Installation Complete!"
echo "==========================================="
echo
echo "You can now launch SQL Developer by running:"
echo "  sqldeveloper"
echo
echo "Or from the applications menu: Oracle SQL Developer"
echo

# Cleanup
rm -f /tmp/sqldeveloper.zip

echo "Done!"
