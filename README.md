# AWX Deployment - Serenity System

Déploiement AWX (Ansible Tower open-source) sur GCP.

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────┐
│              VM GCP e2-medium (2 vCPU, 4GB)             │
│                                                         │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌───────────┐  │
│  │  Nginx  │  │ AWX Web │  │AWX Task │  │PostgreSQL │  │
│  │  :443   │──│  :8052  │  │ worker  │  │   :5432   │  │
│  └─────────┘  └─────────┘  └─────────┘  └───────────┘  │
│                     │            │            │         │
│                     └────────────┴────────────┘         │
│                              │                          │
│                        ┌─────────┐                      │
│                        │  Redis  │                      │
│                        │  :6379  │                      │
│                        └─────────┘                      │
└─────────────────────────────────────────────────────────┘
```

## 📁 Structure

```
awx-deployment/
├── docker-compose.yml      # Stack complète
├── .env.example            # Variables d'environnement
├── nginx/
│   └── nginx.conf          # Reverse proxy + SSL
├── settings/
│   ├── credentials.py      # Config credentials AWX
│   └── execution_environments.py
├── scripts/
│   ├── install.sh          # Installation initiale
│   ├── backup.sh           # Backup données
│   └── setup-ssl.sh        # Certificat Let's Encrypt
└── README.md
```

## 🚀 Installation

### 1. Créer la VM GCP

```bash
gcloud compute instances create awx-controller \
    --machine-type=e2-medium \
    --zone=europe-west1-b \
    --image-family=debian-12 \
    --image-project=debian-cloud \
    --boot-disk-size=50GB \
    --tags=awx,http-server,https-server
```

### 2. Configurer le firewall

```bash
gcloud compute firewall-rules create allow-awx \
    --allow=tcp:80,tcp:443 \
    --target-tags=awx
```

### 3. Installer AWX

```bash
# SSH sur la VM
gcloud compute ssh awx-controller --zone=europe-west1-b

# Cloner et installer
git clone https://github.com/vpaturel/awx-deployment.git /opt/awx-deployment
cd /opt/awx-deployment
cp .env.example .env
nano .env  # Configurer les secrets
chmod +x scripts/*.sh
./scripts/install.sh
```

### 4. Configurer SSL

```bash
./scripts/setup-ssl.sh
```

## 🔐 Configuration

Éditer `.env` avec vos valeurs :

```env
POSTGRES_PASSWORD=<mot_de_passe_fort>
AWX_ADMIN_PASSWORD=<mot_de_passe_admin>
SECRET_KEY=<clé_secrète_64_caractères>
```

Générer une clé secrète :
```bash
openssl rand -hex 32
```

## 📋 Commandes Utiles

```bash
# Voir les logs
docker compose logs -f

# Redémarrer
docker compose restart

# Status
docker compose ps

# Backup manuel
./scripts/backup.sh

# Mise à jour AWX
docker compose pull
docker compose up -d
```

## 🔗 Liens

- AWX UI: https://awx.serenity-system.fr
- AWX API: https://awx.serenity-system.fr/api/v2/
- Documentation: https://ansible.readthedocs.io/projects/awx/

## 🔄 Backup

Backup automatique quotidien via cron :
- PostgreSQL dump
- AWX projects volume

Rétention : 7 jours

## 📊 Monitoring

Health check endpoint : `/api/v2/ping/`

```bash
curl -s https://awx.serenity-system.fr/api/v2/ping/ | jq
```
