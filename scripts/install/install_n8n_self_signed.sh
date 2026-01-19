#!/bin/bash

# Configuration
N8N_DIR="$HOME/n8n"

echo "Updating directories..."
mkdir -p "$N8N_DIR/n8n_data"
mkdir -p "$N8N_DIR/caddy_data"
mkdir -p "$N8N_DIR/caddy_config"
sudo chown -R 1000:1000 "$N8N_DIR/n8n_data"

# Get the Server IP (for the certificate)
SERVER_IP=$(curl -s ifconfig.me)

# Create the Docker Compose file
cat <<EOF > "$N8N_DIR/docker-compose.yml"
services:
  caddy:
    image: caddy:latest
    container_name: caddy
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./caddy_data:/data
      - ./caddy_config:/config
    # 'tls internal' tells Caddy to use a self-signed cert
    command: >
      caddy reverse-proxy
      --from $SERVER_IP
      --to n8n:5678
      --internal-certs

  n8n:
    image: n8nio/n8n:latest
    container_name: n8n
    restart: unless-stopped
    environment:
      - N8N_HOST=$SERVER_IP
      - N8N_PORT=5678
      - N8N_PROTOCOL=https
      - NODE_ENV=production
      - WEBHOOK_URL=https://$SERVER_IP/
      - GENERIC_TIMEZONE=UTC
    volumes:
      - ./n8n_data:/home/node/.n8n
EOF

echo "Adjusting firewall..."
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

echo "Starting n8n with Self-Signed TLS..."
cd "$N8N_DIR"
docker compose up -d

echo "-------------------------------------------------------"
echo "Setup Complete!"
echo "Access n8n at: https://$SERVER_IP"
echo "Note: Your browser will show a warning. This is expected"
echo "with self-signed certificates."
echo "-------------------------------------------------------"