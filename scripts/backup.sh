#!/bin/bash
# Backup AWX data
# Run daily via cron

set -e

BACKUP_DIR="/opt/backups/awx"
DATE=$(date +%Y%m%d_%H%M%S)
RETENTION_DAYS=7

mkdir -p $BACKUP_DIR

echo "=== AWX Backup - $DATE ==="

# Backup PostgreSQL
echo "[1/3] Backing up PostgreSQL..."
docker exec awx-postgres pg_dump -U awx awx | gzip > $BACKUP_DIR/postgres_$DATE.sql.gz

# Backup volumes
echo "[2/3] Backing up volumes..."
docker run --rm \
    -v awx-deployment_awx_projects:/data \
    -v $BACKUP_DIR:/backup \
    alpine tar czf /backup/projects_$DATE.tar.gz -C /data .

# Cleanup old backups
echo "[3/3] Cleaning old backups..."
find $BACKUP_DIR -name "*.gz" -mtime +$RETENTION_DAYS -delete

echo "=== Backup Complete ==="
echo "Files: $BACKUP_DIR"
ls -lh $BACKUP_DIR/*$DATE*
