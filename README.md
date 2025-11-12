# seewaan.com CI/CD Infrastructure

Docker Compose infrastructure for deploying the [Seewaan Nostr client](https://github.com/tkhumush/Seewaan) to seewaan.com with Caddy reverse proxy.

## Architecture

```
Internet → Caddy (SSL/Reverse Proxy) → Seewaan App (React + Vite)
                                        └─ Public Files (.well-known, favicon)
```

### Services

- **seewaan**: React application built from the Seewaan repository
- **caddy**: Reverse proxy with automatic HTTPS via Let's Encrypt

### Key Features

- Automatic SSL certificate management with Caddy
- HTTP/3 support
- Docker-based deployment
- Public file serving (favicon, Nostr NIP-05 identifiers)
- Health checks and automatic restarts

## Quick Start

### Prerequisites

- Docker and Docker Compose installed
- DNS records for seewaan.com pointing to your server
- Ports 80 and 443 open on your firewall

### Deployment

1. Clone this repository:
```bash
git clone https://github.com/tkhumush/seewaan.com.git
cd seewaan.com
```

2. (Optional) Add your favicon:
```bash
cp /path/to/favicon.ico public/favicon.ico
```

3. (Optional) Configure Nostr NIP-05 identifiers:
```bash
nano public/.well-known/nostr.json
```

4. Start the services:
```bash
docker compose up -d
```

5. Check logs:
```bash
docker compose logs -f
```

### First-Time SSL Setup

On first run, Caddy will automatically request SSL certificates from Let's Encrypt. Ensure your DNS records are properly configured before starting.

## CI/CD - Automatic Deployment

This repository includes GitHub Actions for automatic deployment on every push to the `main` branch.

### Setup GitHub Actions

1. **Ensure server has required software**:
   - Git installed
   - Docker and Docker Compose installed
   - SSH user has Docker permissions: `sudo usermod -aG docker $USER`
   - Ports 80 and 443 open

2. **Configure GitHub Secrets** (Repository → Settings → Secrets and variables → Actions):
   - `SERVER_HOST`: Your server IP address or domain
   - `SERVER_USER`: SSH username (e.g., `root` or `ubuntu`)
   - `SSH_PRIVATE_KEY`: Your SSH private key for authentication
   - `SERVER_PORT`: (Optional) SSH port if not 22

3. **Deploy**: Push to main branch, and GitHub Actions will automatically:
   - Clone the repository on first deployment
   - Pull latest changes on subsequent deployments
   - Build and start Docker containers

See [.github/DEPLOYMENT.md](.github/DEPLOYMENT.md) for detailed setup instructions.

### Manual Deployment Script

Alternatively, use the included deployment script:
```bash
./deploy.sh
```

This script will:
- Pull latest changes from git
- Rebuild Docker containers
- Restart services
- Show deployment status and logs
- Clean up old Docker images

## Management

### View Logs
```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f caddy
docker compose logs -f seewaan
```

### Restart Services
```bash
# All services
docker compose restart

# Specific service
docker compose restart seewaan
```

### Update Seewaan App
```bash
# Rebuild and restart
docker compose up -d --build seewaan
```

### Stop Services
```bash
docker compose down
```

### Full Cleanup (including volumes)
```bash
docker compose down -v
```

## Configuration

### Caddyfile

The `Caddyfile` configures:
- Domain: seewaan.com
- SSL certificate management
- Reverse proxy to Seewaan app
- Security headers
- WWW to non-WWW redirect

### Public Files

Files in `public/` are mounted into the container and served by nginx:
- `favicon.ico`: Site favicon
- `.well-known/nostr.json`: Nostr NIP-05 configuration

### Docker Compose

The `docker-compose.yml` defines:
- Service orchestration
- Network isolation
- Volume management
- Health checks

## Monitoring

### Health Checks

Services include health checks:
```bash
docker ps  # Check container health status
```

### Service Status
```bash
docker compose ps
```

## Troubleshooting

### Caddy SSL Issues

Check Caddy logs for certificate errors:
```bash
docker compose logs caddy
```

Ensure DNS is properly configured:
```bash
nslookup seewaan.com
```

### Seewaan App Not Loading

Check container logs:
```bash
docker compose logs seewaan
```

Verify the app is healthy:
```bash
docker inspect seewaan | grep -A 10 Health
```

### Port Conflicts

If ports 80/443 are in use, stop conflicting services:
```bash
sudo lsof -i :80
sudo lsof -i :443
```

## Repository Structure

```
.
├── docker-compose.yml       # Service orchestration
├── Caddyfile               # Reverse proxy configuration
├── deploy.sh               # Manual deployment script
├── .gitignore              # Git ignore rules
├── .env.example            # Environment variables template
├── .github/
│   ├── workflows/
│   │   └── deploy.yml      # GitHub Actions deployment workflow
│   └── DEPLOYMENT.md       # Deployment setup guide
├── seewaan-app/
│   ├── Dockerfile          # Multi-stage build for Seewaan
│   └── nginx.conf          # Nginx configuration
├── public/                 # Public files served by nginx
│   ├── favicon.svg         # Site favicon
│   └── .well-known/
│       └── nostr.json      # Nostr NIP-05 configuration
├── README.md               # This file
└── CLAUDE.md               # AI assistant guidance
```

## Security

- Automatic HTTPS with Let's Encrypt
- Security headers configured in Caddyfile
- Network isolation via Docker bridge network
- No exposed database ports

## License

This infrastructure configuration is provided as-is. The Seewaan application has its own license.
