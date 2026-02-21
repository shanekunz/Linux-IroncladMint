#!/bin/bash
# Setup Home Assistant and Matter Server via Docker
# This script recreates the Docker containers if they don't exist
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}   Home Assistant + Matter Setup${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Error:${NC} Docker is not installed"
    echo -e "Install Docker first: ${BLUE}sudo apt install docker.io${NC}"
    exit 1
fi

# Create data directories if they don't exist
HA_DIR="$HOME/homeassistant"
MATTER_DIR="$HOME/matter-server"

mkdir -p "$HA_DIR"
mkdir -p "$MATTER_DIR"

# Check if containers already exist
HA_EXISTS=$(docker ps -a --filter "name=homeassistant" --format "{{.Names}}" | grep -w homeassistant || true)
MATTER_EXISTS=$(docker ps -a --filter "name=matter-server" --format "{{.Names}}" | grep -w matter-server || true)

# Setup Matter Server (must be running before HA for Matter integration)
if [ -z "$MATTER_EXISTS" ]; then
    echo -e "${YELLOW}Creating Matter Server container...${NC}"
    docker run -d \
        --name matter-server \
        --restart unless-stopped \
        --security-opt apparmor=unconfined \
        -v "$MATTER_DIR:/data" \
        -v /run/dbus:/run/dbus:ro \
        --network host \
        ghcr.io/home-assistant-libs/python-matter-server:stable \
        --storage-path /data \
        --paa-root-cert-dir /data/credentials
    echo -e "${GREEN}Matter Server created!${NC}"
else
    echo -e "${YELLOW}Matter Server container already exists${NC}"
    # Start if not running
    docker start matter-server 2>/dev/null || true
fi

# Setup Home Assistant
if [ -z "$HA_EXISTS" ]; then
    echo -e "${YELLOW}Creating Home Assistant container...${NC}"
    docker run -d \
        --name homeassistant \
        --restart unless-stopped \
        --privileged \
        --network host \
        -e TZ=America/Denver \
        -v "$HA_DIR:/config" \
        -v /run/dbus:/run/dbus:ro \
        ghcr.io/home-assistant/home-assistant:stable
    echo -e "${GREEN}Home Assistant created!${NC}"
else
    echo -e "${YELLOW}Home Assistant container already exists${NC}"
    # Start if not running
    docker start homeassistant 2>/dev/null || true
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}   Setup Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${YELLOW}Access Home Assistant:${NC} http://localhost:8123"
echo ""
echo -e "${YELLOW}Data locations:${NC}"
echo -e "  Home Assistant: $HA_DIR"
echo -e "  Matter Server:  $MATTER_DIR"
echo ""
echo -e "${YELLOW}Important files:${NC}"
echo -e "  HA Token:       $HA_DIR/.ha_token"
echo -e "  HA Config:      $HA_DIR/configuration.yaml"
echo ""
echo -e "${YELLOW}Useful commands:${NC}"
echo -e "  View logs:      ${BLUE}docker logs homeassistant -f${NC}"
echo -e "  Restart HA:     ${BLUE}docker restart homeassistant${NC}"
echo -e "  Stop all:       ${BLUE}docker stop homeassistant matter-server${NC}"
echo ""
