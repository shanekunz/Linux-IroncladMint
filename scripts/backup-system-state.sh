#!/bin/bash
# Backup critical system state that's NOT in dotfiles
# This includes OpenClaw, HomeAssistant, secrets, and other personalization
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

BACKUP_DIR="${BACKUP_DIR:-$HOME/system-backup}"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
BACKUP_NAME="system-state-$TIMESTAMP"
BACKUP_PATH="$BACKUP_DIR/$BACKUP_NAME"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}   System State Backup${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

mkdir -p "$BACKUP_PATH"

# 1. OpenClaw (complete retired state)
echo -e "${YELLOW}Backing up OpenClaw...${NC}"
if [ -d ~/.openclaw ]; then
    mkdir -p "$BACKUP_PATH/openclaw"
    cp -a ~/.openclaw/. "$BACKUP_PATH/openclaw/"
    echo -e "  ${GREEN}OpenClaw backed up${NC}"
else
    echo -e "  ${YELLOW}OpenClaw not found, skipping${NC}"
fi

# 2. Hermes runtime state (config is also managed by dotfiles)
echo -e "${YELLOW}Backing up Hermes...${NC}"
if [ -d ~/.hermes ]; then
    mkdir -p "$BACKUP_PATH/hermes"
    for path in config.yaml SOUL.md auth.json .env google_client_secret.json google_token.json \
        state.db state.db-shm state.db-wal projects.db kanban.db kanban.db-shm kanban.db-wal \
        gateway_state.json channel_directory.json sessions memories mcp-tokens cron; do
        cp -a "$HOME/.hermes/$path" "$BACKUP_PATH/hermes/" 2>/dev/null || true
    done
    echo -e "  ${GREEN}Hermes runtime state backed up${NC}"
else
    echo -e "  ${YELLOW}Hermes not found, skipping${NC}"
fi

# 3. mcporter configuration and credentials
echo -e "${YELLOW}Backing up mcporter...${NC}"
if [ -d ~/.mcporter ]; then
    mkdir -p "$BACKUP_PATH/mcporter"
    cp -a ~/.mcporter/. "$BACKUP_PATH/mcporter/"
    echo -e "  ${GREEN}mcporter backed up${NC}"
else
    echo -e "  ${YELLOW}mcporter not found, skipping${NC}"
fi

# 4. HomeAssistant config (not the database, just config)
echo -e "${YELLOW}Backing up HomeAssistant config...${NC}"
if [ -d ~/homeassistant ]; then
    mkdir -p "$BACKUP_PATH/homeassistant"
    cp ~/homeassistant/configuration.yaml "$BACKUP_PATH/homeassistant/" 2>/dev/null || true
    cp ~/homeassistant/automations.yaml "$BACKUP_PATH/homeassistant/" 2>/dev/null || true
    cp ~/homeassistant/scenes.yaml "$BACKUP_PATH/homeassistant/" 2>/dev/null || true
    cp ~/homeassistant/scripts.yaml "$BACKUP_PATH/homeassistant/" 2>/dev/null || true
    cp ~/homeassistant/secrets.yaml "$BACKUP_PATH/homeassistant/" 2>/dev/null || true
    cp ~/homeassistant/.ha_token "$BACKUP_PATH/homeassistant/" 2>/dev/null || true
    # Helper scripts
    cp ~/homeassistant/*.mjs "$BACKUP_PATH/homeassistant/" 2>/dev/null || true
    echo -e "  ${GREEN}HomeAssistant config backed up${NC}"
else
    echo -e "  ${YELLOW}HomeAssistant not found, skipping${NC}"
fi

# 5. Matter server state (device pairings are critical!)
echo -e "${YELLOW}Backing up Matter server...${NC}"
if [ -d ~/matter-server ]; then
    mkdir -p "$BACKUP_PATH/matter-server"
    # The JSON files contain device pairings
    cp ~/matter-server/*.json "$BACKUP_PATH/matter-server/" 2>/dev/null || true
    cp ~/matter-server/*.ini "$BACKUP_PATH/matter-server/" 2>/dev/null || true
    # Credentials for paired devices
    cp -r ~/matter-server/credentials "$BACKUP_PATH/matter-server/" 2>/dev/null || true
    echo -e "  ${GREEN}Matter server backed up${NC}"
else
    echo -e "  ${YELLOW}Matter server not found, skipping${NC}"
fi

# 6. Secrets file
echo -e "${YELLOW}Backing up secrets...${NC}"
if [ -f ~/.secrets ]; then
    cp ~/.secrets "$BACKUP_PATH/secrets"
    chmod 600 "$BACKUP_PATH/secrets"
    echo -e "  ${GREEN}Secrets backed up${NC}"
else
    echo -e "  ${YELLOW}~/.secrets not found, skipping${NC}"
fi

# 7. GOG CLI credentials
echo -e "${YELLOW}Backing up GOG CLI...${NC}"
if [ -d ~/.config/gogcli ]; then
    mkdir -p "$BACKUP_PATH/gogcli"
    cp -r ~/.config/gogcli/* "$BACKUP_PATH/gogcli/" 2>/dev/null || true
    echo -e "  ${GREEN}GOG CLI backed up${NC}"
fi

# 8. OpenCode/Antigravity accounts
echo -e "${YELLOW}Backing up OpenCode config...${NC}"
if [ -d ~/.config/opencode ]; then
    mkdir -p "$BACKUP_PATH/opencode"
    cp ~/.config/opencode/antigravity-accounts.json "$BACKUP_PATH/opencode/" 2>/dev/null || true
    cp ~/.config/opencode/opencode.json "$BACKUP_PATH/opencode/" 2>/dev/null || true
    echo -e "  ${GREEN}OpenCode backed up${NC}"
fi

# 9. JIRA CLI config
echo -e "${YELLOW}Backing up JIRA CLI...${NC}"
if [ -d ~/.config/.jira ]; then
    mkdir -p "$BACKUP_PATH/jira"
    cp ~/.config/.jira/.config.yml "$BACKUP_PATH/jira/" 2>/dev/null || true
    echo -e "  ${GREEN}JIRA CLI backed up${NC}"
fi

# 10. Keyrings (optional - contains encrypted passwords)
echo -e "${YELLOW}Backing up keyrings...${NC}"
if [ -d ~/.local/share/keyrings ]; then
    mkdir -p "$BACKUP_PATH/keyrings"
    cp ~/.local/share/keyrings/*.keyring "$BACKUP_PATH/keyrings/" 2>/dev/null || true
    echo -e "  ${GREEN}Keyrings backed up${NC}"
fi

# 11. OpenClaw systemd service overrides (contains API keys!)
echo -e "${YELLOW}Backing up systemd service overrides...${NC}"
if [ -d ~/.config/systemd/user/openclaw-gateway.service.d ]; then
    mkdir -p "$BACKUP_PATH/systemd"
    cp ~/.config/systemd/user/openclaw-gateway.service.d/*.conf "$BACKUP_PATH/systemd/" 2>/dev/null || true
    echo -e "  ${GREEN}Systemd overrides backed up${NC}"
fi

# Create archive
echo ""
echo -e "${YELLOW}Creating encrypted archive...${NC}"
ARCHIVE_PATH="$BACKUP_DIR/$BACKUP_NAME.tar.gz.gpg"

# Create tarball
cd "$BACKUP_DIR"
tar -czf "$BACKUP_NAME.tar.gz" "$BACKUP_NAME"

# Encrypt with GPG (symmetric, password-based)
echo -e "${BLUE}Enter a password to encrypt the backup:${NC}"
gpg --symmetric --cipher-algo AES256 -o "$ARCHIVE_PATH" "$BACKUP_NAME.tar.gz"

# Cleanup unencrypted files
rm -rf "$BACKUP_PATH"
rm -f "$BACKUP_DIR/$BACKUP_NAME.tar.gz"

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                    BACKUP COMPLETE!                            ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}BACKUP LOCATION:${NC}"
echo -e "  $ARCHIVE_PATH"
echo -e "  Size: $(du -h "$ARCHIVE_PATH" | cut -f1)"
echo ""
echo -e "${BLUE}WHAT'S INCLUDED:${NC}"
echo -e "  • OpenClaw (complete retired state)"
echo -e "  • Hermes (memory, sessions, auth, and runtime databases)"
echo -e "  • mcporter (configuration and credentials)"
echo -e "  • HomeAssistant (config, automations, token)"
echo -e "  • Matter server (device pairings)"
echo -e "  • ~/.secrets (API keys)"
echo -e "  • GOG CLI, OpenCode, JIRA config"
echo -e "  • Keyrings"
echo ""
echo -e "${BLUE}TO RESTORE ON A NEW SYSTEM:${NC}"
echo -e "  1. Copy backup file to new machine"
echo -e "  2. Run: ${YELLOW}gpg -d $BACKUP_NAME.tar.gz.gpg | tar -xzf -${NC}"
echo -e "  3. Move files to their original locations:"
echo -e "     ${YELLOW}cp -a $BACKUP_NAME/openclaw/. ~/.openclaw/${NC}"
echo -e "     ${YELLOW}cp -a $BACKUP_NAME/hermes/. ~/.hermes/${NC}"
echo -e "     ${YELLOW}cp -a $BACKUP_NAME/mcporter/. ~/.mcporter/${NC}"
echo -e "     ${YELLOW}cp -r $BACKUP_NAME/homeassistant/* ~/homeassistant/${NC}"
echo -e "     ${YELLOW}cp -r $BACKUP_NAME/matter-server/* ~/matter-server/${NC}"
echo -e "     ${YELLOW}cp $BACKUP_NAME/secrets ~/.secrets${NC}"
echo ""
echo -e "${BLUE}UPLOAD TO iCLOUD:${NC}"
echo -e "  Your iCloud Drive is likely at: ~/Library/Mobile Documents/com~apple~CloudDocs/"
echo -e "  Or on Linux with iCloud mounted: Check your mount point"
echo -e ""
echo -e "  Manual upload: Open Files app and drag the backup to your cloud folder"
echo ""
echo -e "${YELLOW}Press Enter to exit...${NC}"
read
