#!/bin/bash
# Setup Let's Encrypt SSL Certificate
# Run after DNS is configured

set -e

DOMAIN="awx.serenity-system.fr"
EMAIL="vincent.paturel@serenity-system.fr"

echo "=== SSL Certificate Setup ==="

# Stop nginx temporarily
docker compose stop nginx 2>/dev/null || true

# Get certificate
certbot certonly --standalone \
    -d $DOMAIN \
    --email $EMAIL \
    --agree-tos \
    --non-interactive

# Create symlinks for docker
mkdir -p /opt/awx-deployment/nginx/certs
ln -sf /etc/letsencrypt/live/$DOMAIN /opt/awx-deployment/nginx/certs/

# Restart nginx
docker compose up -d nginx

echo "=== SSL Setup Complete ==="
echo "Certificate installed for $DOMAIN"

# Setup auto-renewal
echo "0 3 * * * certbot renew --quiet --post-hook 'docker compose -f /opt/awx-deployment/docker-compose.yml restart nginx'" | crontab -
echo "Auto-renewal cron job added"
