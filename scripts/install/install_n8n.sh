#!/bin/bash

# Define the installation directory
N8N_DIR="$HOME/n8n"

echo "Creating n8n directory at $N8N_DIR..."
mkdir -p "$N8N_DIR/n8n_data"

# Set ownership to node user (UID 1000) used inside the n8n container
# This prevents "Permission Denied" errors when n8n tries to save data.
sudo chown -R 1000:1000 "$N8N_DIR/n8n_data"

# Create the Docker Compose file
cat <<EOF > "$N8N_DIR/docker-compose.yml"
services:
  n8n:
    image: n8nio/n8n:latest
    container_name: n8n
    restart: unless-stopped
    ports:
      - "5678:5678"
    environment:
      - N8N_HOST=localhost
      - N8N_PORT=5678
      - N8N_PROTOCOL=http
      - NODE_ENV=production
      - WEBHOOK_URL=http://localhost:5678/
      - GENERIC_TIMEZONE=UTC
    volumes:
      - ./n8n_data:/home/node/.n8n
EOF

echo "Starting n8n..."
cd "$N8N_DIR"
docker compose up -d

echo "-------------------------------------------------------"
echo "n8n is now running!"
echo "Access it at: http://$(curl -s ifconfig.me):5678"
echo "-------------------------------------------------------"