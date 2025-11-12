# Deployment Setup Guide

This guide explains how to set up automatic deployment to your server via GitHub Actions.

## Required GitHub Secrets

Navigate to your GitHub repository → Settings → Secrets and variables → Actions, and add these secrets:

### 1. `SERVER_HOST`
The IP address or domain of your server.
```
Example: 123.45.67.89
```

### 2. `SERVER_USER`
The SSH username to connect to your server.
```
Example: root
or: ubuntu
```

### 3. `SSH_PRIVATE_KEY`
Your SSH private key for authentication.

**To generate and add:**

```bash
# On your local machine, generate SSH key pair
ssh-keygen -t ed25519 -C "github-actions-seewaan" -f ~/.ssh/github-actions-seewaan

# Copy the PUBLIC key to your server
ssh-copy-id -i ~/.ssh/github-actions-seewaan.pub user@your-server-ip

# Test the connection
ssh -i ~/.ssh/github-actions-seewaan user@your-server-ip

# Copy the PRIVATE key content for GitHub secret
cat ~/.ssh/github-actions-seewaan
# Copy the entire output (including BEGIN and END lines)
```

Paste the entire private key (including `-----BEGIN` and `-----END` lines) into the `SSH_PRIVATE_KEY` secret.

### 4. `SERVER_PORT` (Optional)
SSH port if not using default port 22.
```
Example: 2222
```

## Server Requirements

Your production server needs:
- **Git** installed: `git --version`
- **Docker** installed: `docker --version`
- **Docker Compose** installed: `docker compose version`
- **User has Docker permissions**: `sudo usermod -aG docker $USER` (re-login after)
- **Ports 80 and 443** open in firewall

**That's it!** The GitHub Actions workflow will automatically:
- Clone the repository on first deployment (to `/opt/seewaan.com` or `~/seewaan.com`)
- Pull latest changes on subsequent deployments
- Build and deploy with Docker

## Optional: Manual Server Setup

If you prefer to set up the server manually before the first automated deployment:

```bash
# Clone the repository on your server
sudo mkdir -p /opt/seewaan.com
sudo chown $USER:$USER /opt/seewaan.com
cd /opt
git clone https://github.com/tkhumush/seewaan.com.git
cd seewaan.com

# Initial deployment
docker compose up -d --build
```

## How Auto-Deployment Works

1. You push code to the `main` branch
2. GitHub Actions triggers the workflow
3. The workflow connects to your server via SSH
4. **First time**: Clones the repository to `/opt/seewaan.com` (or `~/seewaan.com`)
5. **Subsequent times**: Pulls the latest code
6. Rebuilds and restarts Docker containers
7. Shows deployment status and logs

## Manual Deployment

You can also trigger deployment manually:
1. Go to Actions tab in GitHub
2. Select "Deploy to Production" workflow
3. Click "Run workflow"
4. Select branch and click "Run workflow"

## Troubleshooting

### SSH Connection Failed
- Verify `SERVER_HOST` is correct
- Check `SERVER_USER` has SSH access
- Ensure `SSH_PRIVATE_KEY` is the complete private key
- Verify firewall allows SSH (port 22 or custom port)

### Docker Commands Fail
- Ensure Docker is installed on server: `docker --version`
- Ensure user has Docker permissions: `sudo usermod -aG docker $USER`
- Re-login after adding user to docker group

### Git Pull Fails
- Ensure repository is cloned on server
- Check git remote is correct: `git remote -v`
- Verify branch exists: `git branch -a`

### Permission Errors
```bash
# On server, fix ownership
sudo chown -R $USER:$USER /opt/seewaan.com
```

## Deployment Logs

View deployment logs in GitHub:
1. Go to Actions tab
2. Click on the latest workflow run
3. Click on "Deploy to seewaan.com" job
4. Expand steps to see detailed logs

## Rollback

If deployment fails, you can rollback on the server:

```bash
ssh user@your-server-ip
cd /opt/seewaan.com

# View commit history
git log --oneline

# Rollback to previous commit
git reset --hard <commit-hash>

# Rebuild
docker compose up -d --build
```
