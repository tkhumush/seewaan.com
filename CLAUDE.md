# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

CI/CD infrastructure repository for deploying seewaan.com - a Nostr client application built from https://github.com/tkhumush/Seewaan.git. The infrastructure uses Docker Compose with Caddy as a reverse proxy to serve the React application with automatic HTTPS.

## Architecture

**Multi-service Docker Compose setup:**
- **seewaan service**: Builds the Seewaan React app from GitHub, serves via nginx on internal port 80
- **caddy service**: Reverse proxy on ports 80/443/443(UDP) with automatic Let's Encrypt SSL certificates

**Request flow:** Internet → Caddy (SSL termination) → seewaan container (nginx) → React app

**Public files:** The `public/` directory is mounted as a volume and served by nginx for favicon and `.well-known/nostr.json` (Nostr NIP-05 identifiers)

## Common Commands

### Build and Deploy
```bash
# Start all services
docker compose up -d

# Rebuild Seewaan app (e.g., after upstream changes)
docker compose up -d --build seewaan

# View build logs
docker compose logs -f seewaan
```

### Monitoring
```bash
# View all logs
docker compose logs -f

# View specific service logs
docker compose logs -f caddy
docker compose logs -f seewaan

# Check service status and health
docker compose ps
docker ps  # Shows health check status
```

### Maintenance
```bash
# Restart services
docker compose restart

# Stop services
docker compose down

# Stop and remove volumes (full cleanup)
docker compose down -v

# Rebuild specific service
docker compose build seewaan
```

### Debugging
```bash
# Access container shell
docker exec -it seewaan sh
docker exec -it caddy sh

# Check nginx configuration
docker exec seewaan nginx -t

# View Caddy configuration
docker exec caddy cat /etc/caddy/Caddyfile
```

### CI/CD and Deployment
```bash
# Manual deployment using script
./deploy.sh

# GitHub Actions auto-deploys on push to main branch
# Workflow file: .github/workflows/deploy.yml
```

**Required GitHub Secrets:**
- `SERVER_HOST`: Server IP or domain
- `SERVER_USER`: SSH username
- `SSH_PRIVATE_KEY`: SSH private key for authentication
- `SERVER_PORT`: (Optional) SSH port

**Deployment flow:**
1. Push to main branch
2. GitHub Actions connects via SSH
3. Pulls latest code on server
4. Runs `docker compose down && docker compose up -d --build`
5. Displays deployment status and logs

See `.github/DEPLOYMENT.md` for detailed setup instructions.

## Key Files and Their Purposes

**docker-compose.yml**: Service orchestration with health checks, restart policies, and volume management

**Caddyfile**: Reverse proxy configuration for seewaan.com with automatic HTTPS, security headers, and www redirect

**seewaan-app/Dockerfile**: Multi-stage build that clones Seewaan repo, runs `npm run build`, and serves with nginx

**seewaan-app/nginx.conf**: Nginx configuration for:
- Serving React app with SPA routing (all routes → index.html)
- Public files at `/public/`, `/favicon.ico`, and `/.well-known/`
- Static asset caching and gzip compression

**public/.well-known/nostr.json**: Nostr NIP-05 identifier configuration (CORS-enabled, application/json)

## Development Guidelines

### Modifying the Seewaan Application

The Seewaan app is built from the upstream repository during Docker build. To use a different version or fork:

1. Edit `seewaan-app/Dockerfile`, line 8:
   ```dockerfile
   git clone https://github.com/tkhumush/Seewaan.git .
   ```

2. Rebuild: `docker compose up -d --build seewaan`

### Adding Public Files

Files in `public/` are volume-mounted and served by nginx:

1. Add file to `public/` directory
2. Restart seewaan service: `docker compose restart seewaan`
3. Files are immediately available (no rebuild needed)

### Caddy Configuration Changes

After modifying `Caddyfile`:
```bash
# Reload Caddy configuration
docker compose restart caddy

# Or reload without restart
docker exec caddy caddy reload --config /etc/caddy/Caddyfile
```

### SSL Certificate Management

Caddy handles Let's Encrypt certificates automatically. Certificates are stored in the `caddy_data` volume.

**Requirements:**
- DNS A/AAAA records for seewaan.com must point to the server
- Ports 80 and 443 must be accessible from the internet
- On first run, Caddy will request certificates (check logs: `docker compose logs caddy`)

**Testing before production:**
- Use Caddy's staging environment by adding `acme_ca https://acme-staging-v02.api.letsencrypt.org/directory` to Caddyfile

## Nostr NIP-05 Configuration

Edit `public/.well-known/nostr.json`:
```json
{
  "names": {
    "username": "npub1hexadecimal..."
  },
  "relays": {
    "npub1hexadecimal...": [
      "wss://relay.example.com",
      "wss://another-relay.example.com"
    ]
  }
}
```

This allows Nostr users to be identified as `username@seewaan.com`. The file is served with CORS headers.

## Network Architecture

All services communicate on the `seewaan-network` Docker bridge network:
- Caddy proxies to `seewaan:80` (container name resolution)
- External access only through Caddy on ports 80/443
- No other ports exposed to the host

## Health Checks

**seewaan service:**
- Checks `http://localhost:80` every 30s
- 40s startup grace period
- Container marked unhealthy after 3 failures

Use `docker ps` to see health status in the STATUS column.

## Volumes

**caddy_data**: SSL certificates and Caddy data (persistent)
**caddy_config**: Caddy configuration cache (persistent)
**./public**: Public files bind mount (live sync, no rebuild needed)

## Reference Architecture

This repository replicates the architecture from https://github.com/tkhumush/nostrarabiarelay.git:
- Docker Compose orchestration
- Caddy reverse proxy with automatic HTTPS
- Multi-service containerized deployment
- Volume management for persistent data
