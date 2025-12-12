#!/bin/bash
# AWX Installation Script for GCP VM
# Run this on a fresh Debian 12 VM

set -e

echo "=== AWX Installation Script ==="
echo "Target: GCP e2-medium (2 vCPU, 4GB RAM)"

# Update system
echo "[1/7] Updating system..."
apt-get update && apt-get upgrade -y

# Install dependencies
echo "[2/7] Installing dependencies..."
apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    git \
    jq \
    certbot

# Install Docker
echo "[3/7] Installing Docker..."
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Start Docker
echo "[4/7] Starting Docker..."
systemctl enable docker
systemctl start docker

# Clone AWX deployment repo
echo "[5/7] Cloning AWX deployment..."
cd /opt
git clone https://github.com/vpaturel/awx-deployment.git
cd awx-deployment

# Setup environment
echo "[6/7] Setting up environment..."
if [ ! -f .env ]; then
    cp .env.example .env
    echo "⚠️  Please edit /opt/awx-deployment/.env with your secrets"
    echo "    Then run: docker compose up -d"
    exit 1
fi

# Start AWX
echo "[7/7] Starting AWX..."
docker compose up -d

echo ""
echo "=== Installation Complete ==="
echo "AWX will be available at https://awx.serenity-system.fr"
echo "Default admin: admin / (check .env)"
echo ""
echo "Useful commands:"
echo "  docker compose logs -f          # View logs"
echo "  docker compose ps               # Check status"
echo "  docker compose restart          # Restart services"
