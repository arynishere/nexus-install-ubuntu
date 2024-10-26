#!/bin/bash

echo "
 _      ________  _ _     ____    _  _      ____  _____  ____  _     _       ____  ____  ____  _  ____  _____    ____ ___  _   ____  ____  _  ____  _     
/ \  /|/  __/\  \/// \ /\/ ___\  / \/ \  /|/ ___\/__ __\/  _ \/ \   / \     / ___\/   _\/  __\/ \/  __\/__ __\  /  _ \\  \//  /  _ \/  __\/ \/  _ \/ \  /|
| |\ |||  \   \  / | | |||    \  | || |\ |||    \  / \  | / \|| |   | |     |    \|  /  |  \/|| ||  \/|  / \    | | // \  /   | / \||  \/|| || / \|| |\ ||
| | \|||  /_  /  \ | \_/|\___ |  | || | \||\___ |  | |  | |-||| |_/\| |_/\  \___ ||  \_ |    /| ||  __/  | |    | |_\\ / /    | |-|||    /| || |-||| | \||
\_/  \|\____\/__/\\\____/\____/  \_/\_/  \|\____/  \_/  \_/ \|\____/\____/  \____/\____/\_/\_\\_/\_/     \_/    \____//_/     \_/ \|\_/\_\\_/\_/ \|\_/  \|
"

sleep 3

# Step 1: Update and upgrade the system
echo "Updating system packages..."
sudo apt update || { echo "Failed to update and upgrade packages"; exit 1; }

# Step 2: Install Java (OpenJDK 8)
echo "Installing OpenJDK 8..."
sudo apt install openjdk-8-jre-headless -y || { echo "Failed to install OpenJDK 8"; exit 1; }

# Step 3: Add a new user for Nexus
echo "Creating Nexus user..."
sudo adduser --disabled-login --no-create-home --gecos "" nexus || { echo "Failed to create Nexus user"; exit 1; }

# Step 4: Download and extract Nexus
cd /opt || { echo "Failed to change directory to /opt"; exit 1; }
echo "Downloading and extracting Nexus..."
sudo wget https://download.sonatype.com/nexus/3/nexus-3.41.1-01-unix.tar.gz || { echo "Failed to download Nexus"; exit 1; }
sudo tar -xvf nexus-3.41.1-01-unix.tar.gz || { echo "Failed to extract Nexus"; exit 1; }

# Step 5: Move Nexus directory and set permissions
echo "Renaming Nexus directory and setting permissions..."
sudo mv nexus-3.41.1-01/ nexus || { echo "Failed to rename Nexus directory"; exit 1; }
sudo chown -R nexus:nexus /opt/nexus || { echo "Failed to set ownership for /opt/nexus"; exit 1; }
sudo chown -R nexus:nexus /opt/sonatype-work || { echo "Failed to set ownership for /opt/sonatype-work"; exit 1; }

# Step 6: Add run_as_user="nexus" to /opt/nexus/bin/nexus.rc
NEXUS_RC_FILE="/opt/nexus/bin/nexus.rc"
if grep -q 'run_as_user="nexus"' "$NEXUS_RC_FILE"; then
  echo "'run_as_user=\"nexus\"' already exists in $NEXUS_RC_FILE"
else
  echo 'run_as_user="nexus"' | sudo tee -a "$NEXUS_RC_FILE" > /dev/null
  echo "Added 'run_as_user=\"nexus\"' to $NEXUS_RC_FILE"
fi

# Step 7: Configure nexus.vmoptions
NEXUS_VMOPTIONS_FILE="/opt/nexus/bin/nexus.vmoptions"
echo "Configuring nexus.vmoptions..."
sudo tee "$NEXUS_VMOPTIONS_FILE" > /dev/null <<EOF
-Xms1024m
-Xmx1024m
-XX:MaxDirectMemorySize=1024m
-XX:+UnlockDiagnosticVMOptions
-XX:+LogVMOutput
-XX:LogFile=../sonatype-work/nexus3/log/jvm.log
-XX:-OmitStackTraceInFastThrow
-Djava.net.preferIPv4Stack=true
-Dkaraf.home=.
-Dkaraf.base=.
-Dkaraf.etc=etc/karaf
-Djava.util.logging.config.file=etc/karaf/java.util.logging.properties
-Dkaraf.data=../sonatype-work/nexus3
-Dkaraf.log=../sonatype-work/nexus3/log
-Djava.io.tmpdir=../sonatype-work/nexus3/tmp
-Dkaraf.startLocalConsole=false
-Djdk.tls.ephemeralDHKeySize=2048
# comment out this vmoption when using Java9+
-Djava.endorsed.dirs=lib/endorsed
EOF
echo "Updated $NEXUS_VMOPTIONS_FILE"

# Step 8: Create the nexus systemd service file
NEXUS_SERVICE_FILE="/etc/systemd/system/nexus.service"
echo "Creating Nexus systemd service..."
sudo tee "$NEXUS_SERVICE_FILE" > /dev/null <<EOF
[Unit]
Description=Nexus service
After=network.target

[Service]
Type=forking
LimitNOFILE=65536
ExecStart=/opt/nexus/bin/nexus start
ExecStop=/opt/nexus/bin/nexus stop
User=nexus
Restart=on-abort

[Install]
WantedBy=multi-user.target
EOF
echo "Created $NEXUS_SERVICE_FILE"

# Step 9: Reload systemd, start and enable Nexus service
echo "Reloading systemd and starting Nexus service..."
sudo systemctl daemon-reload || { echo "Failed to reload systemd"; exit 1; }
sudo systemctl start nexus || { echo "Failed to start Nexus service"; exit 1; }
sudo systemctl enable nexus || { echo "Failed to enable Nexus service"; exit 1; }

echo "Nexus setup completed successfully!"
