#!/bin/bash
set -e

# Log everything to a file for debugging
exec > >(tee /var/log/user-data.log)
exec 2>&1

echo "Starting Minecraft server setup..."

# Update and install dependencies
echo "Installing dependencies..."
apt update
apt install -y openjdk-8-jre-headless zip

# Create minecraft directory in ubuntu user's home
echo "Creating minecraft directory..."
mkdir -p /home/ubuntu/minecraft
cd /home/ubuntu/minecraft
chown -R ubuntu:ubuntu /home/ubuntu/minecraft

# Download Minecraft server
echo "Downloading Minecraft server..."
wget https://launcher.mojang.com/v1/objects/1b557e7b033b583cd9f66746b7a9ab1ec1673ced/server.jar -O mc-server-1.16.5.jar

# Accept EULA
echo "Accepting EULA..."
echo "eula=true" > eula.txt

# Create server.properties with online-mode=false
echo "Creating server.properties..."
cat > server.properties <<'PROPS'
#Minecraft server properties
enable-jmx-monitoring=false
rcon.port=25575
level-seed=
gamemode=survival
enable-command-block=false
enable-query=false
generator-settings={}
enforce-secure-profile=true
level-name=world
motd=A Minecraft Server
query.port=25565
pvp=true
generate-structures=true
max-chained-neighbor-updates=1000000
difficulty=easy
network-compression-threshold=256
max-tick-time=60000
require-resource-pack=false
use-native-transport=true
max-players=20
online-mode=false
enable-status=true
allow-flight=false
initial-disabled-packs=
broadcast-rcon-to-ops=true
view-distance=10
server-ip=
resource-pack-prompt=
allow-nether=true
server-port=25565
enable-rcon=false
sync-chunk-writes=true
op-permission-level=4
prevent-proxy-connections=false
hide-online-players=false
resource-pack=
entity-broadcast-range-percentage=100
simulation-distance=10
rcon.password=
player-idle-timeout=0
force-gamemode=false
rate-limit=0
hardcore=false
white-list=false
broadcast-console-to-ops=true
spawn-npcs=true
spawn-animals=true
log-ips=true
function-permission-level=2
initial-enabled-packs=vanilla
level-type=minecraft\:normal
text-filtering-config=
spawn-monsters=true
enforce-whitelist=false
spawn-protection=16
resource-pack-sha1=
max-world-size=29999984
PROPS

# Create systemd service file
echo "Creating systemd service..."
cat > /etc/systemd/system/minecraft.service <<'SERVICE'
[Unit]
Description=Minecraft Server
After=network.target

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/home/ubuntu/minecraft
ExecStart=/usr/bin/java -Xms1024M -Xmx1024M -jar mc-server-1.16.5.jar nogui
Restart=on-failure
RestartSec=10
StandardOutput=append:/var/log/minecraft.log
StandardError=append:/var/log/minecraft.log

[Install]
WantedBy=multi-user.target
SERVICE

# Enable and start the service
echo "Enabling and starting Minecraft service..."
systemctl daemon-reload
systemctl enable minecraft.service
systemctl start minecraft.service

# Wait a moment and check status
sleep 5
echo "Service status:"
systemctl status minecraft.service --no-pager || true

echo "Setup complete! Server should be starting up..."
echo "Check /var/log/minecraft.log for server logs"
