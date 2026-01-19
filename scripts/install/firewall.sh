#!/bin/bash

echo "Configuring UFW Firewall..."

# Allow SSH first so you don't get locked out of your server!
sudo ufw allow ssh

# Allow n8n traffic
sudo ufw allow 5678/tcp

# (Optional) Allow standard web traffic if you plan to use a reverse proxy later
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Enable firewall (it will prompt for confirmation)
# The 'yes' command bypasses the manual confirmation prompt
echo "y" | sudo ufw enable

echo "-------------------------------------------------------"
echo "Firewall status:"
sudo ufw status
echo "-------------------------------------------------------"