#!/bin/bash

# Deployment script for seewaan.com
# This script can be used for manual deployments

set -e  # Exit on error

echo "🚀 Starting deployment for seewaan.com..."

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker is not installed${NC}"
    exit 1
fi

# Check if docker compose is available
if ! docker compose version &> /dev/null; then
    echo -e "${RED}❌ Docker Compose is not available${NC}"
    exit 1
fi

# Pull latest changes (if in git repo)
if [ -d .git ]; then
    echo -e "${BLUE}📥 Pulling latest changes from git...${NC}"
    git pull origin main
else
    echo -e "${BLUE}ℹ️  Not a git repository, skipping git pull${NC}"
fi

# Stop existing containers
echo -e "${BLUE}🛑 Stopping existing containers...${NC}"
docker compose down

# Rebuild and start containers
echo -e "${BLUE}🏗️  Building and starting containers...${NC}"
docker compose up -d --build

# Wait for services to be healthy
echo -e "${BLUE}⏳ Waiting for services to be healthy...${NC}"
sleep 10

# Check service status
echo -e "${BLUE}📊 Service status:${NC}"
docker compose ps

# Show recent logs
echo -e "${BLUE}📝 Recent logs:${NC}"
docker compose logs --tail=20

# Clean up old images
echo -e "${BLUE}🧹 Cleaning up old Docker images...${NC}"
docker image prune -f

echo -e "${GREEN}✅ Deployment complete!${NC}"
echo -e "${GREEN}🌐 Visit https://seewaan.com${NC}"
