#!/bin/bash
set -e

ERROR_LOG="entrypoint_error.log"
> "$ERROR_LOG"  # Alte Logdatei leeren

# ----------------------------
# Colors via tput
# ----------------------------
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
CYAN=$(tput setaf 6)
NC=$(tput sgr0)

# ----------------------------
# Functions
# ----------------------------
msg() {
    local color="$1"
    shift
    if [ "$color" = "RED" ]; then
        printf "%b\n" "${RED}$*${NC}" | tee -a "$ERROR_LOG" >&2
    else
        printf "%b\n" "${!color}$*${NC}"
    fi
}

line() {
    local color="${1:-BLUE}"
    local term_width=$(tput cols 2>/dev/null || echo 70)
    local sep=$(printf '%*s' "$term_width" '' | tr ' ' '-')

    case "$color" in
        RED) COLOR="$RED";;
        GREEN) COLOR="$GREEN";;
        YELLOW) COLOR="$YELLOW";;
        BLUE) COLOR="$BLUE";;
        CYAN) COLOR="$CYAN";;
        *) COLOR="$NC";;
    esac
    printf "%b\n" "${COLOR}${sep}${NC}"
}

cleanup() {
    msg YELLOW "Cleaning up..."
    # Simple cleanup - mongod --shutdown will handle MongoDB
}

# ----------------------------
# Error trap
# ----------------------------
trap 'echo "$(date +"%Y-%m-%d %H:%M:%S") - Unexpected error at line $LINENO" | tee -a "$ERROR_LOG" >&2' ERR
trap cleanup EXIT

# ----------------------------
# Environment
# ----------------------------
cd /home/container || { msg RED "Failed to change directory to /home/container."; exit 1; }

sleep 1

export TZ=${TZ:-UTC}

# Get internal IP with better error handling
INTERNAL_IP=""
INTERNAL_IP=$(ip route get 1 2>/dev/null | awk '{print $(NF-2);exit}' || echo "127.0.0.1")
export INTERNAL_IP

# ----------------------------
# System Info
# ----------------------------
clear
line BLUE
msg RED "NodeJS & MongoDB Image by gOOvER - https://discord.goover.dev"
msg RED "This Image is licencend under AGPLv3"
line BLUE
msg YELLOW "Running on: ${RED}$(. /etc/os-release ; echo $NAME $VERSION)"
msg YELLOW "Current timezone: ${RED}$(cat /etc/timezone)"
line BLUE
msg YELLOW "NodeJS Version: ${RED}$(node -v)"
msg YELLOW "BUN Version: ${RED}$(bun --version)"
msg YELLOW "npm Version: ${RED}$(npm -v)"
msg YELLOW "MongoDB Version: ${RED}$(mongod --version | head -n 1)"
line BLUE

# ----------------------------
# Start MongoDB
# ----------------------------
line BLUE
msg YELLOW "Starting MongoDB..."
line BLUE

# Ensure MongoDB directory exists and has correct permissions
mkdir -p /home/container/mongodb
chown -R container:container /home/container/mongodb 2>/dev/null || true

# Check for MongoDB version compatibility issues and clean if needed
if [ -f "/home/container/mongodb/_mdb_catalog.wt" ] || [ -f "/home/container/mongodb/WiredTiger.wt" ]; then
    line YELLOW
    msg YELLOW "Existing MongoDB data detected - checking compatibility..."

    # Check if this is an older MongoDB version by looking at storage.bson or collection files
    # MongoDB 7.x uses different internal structure than 8.x
    if [ -f "/home/container/mongodb/storage.bson" ]; then
        # Try to detect version incompatibility by attempting a quick mongod check
        line CYAN
        msg YELLOW "Testing MongoDB compatibility..."

        # Start mongod briefly to check for version errors
        mongod --dbpath /home/container/mongodb/ --port 27018 --logpath /tmp/mongo_test.log --fork 2>/dev/null || true
        sleep 2

        # Check if the test log contains version compatibility errors
        if grep -q "Wrong mongod version\|Invalid featureCompatibilityVersion\|featureCompatibilityVersion.*7\." /tmp/mongo_test.log 2>/dev/null; then
            line RED
            msg RED "CRITICAL: MongoDB 8.2 cannot upgrade directly from 7.x data!"
            line RED
            msg YELLOW "According to MongoDB documentation, 8.2 requires upgrade path: 7.x → 8.0 → 8.2"
            msg YELLOW "Direct upgrade from featureCompatibilityVersion 7.x to 8.2 is not supported."
            line YELLOW
            msg YELLOW "AUTO-BACKUP: Moving incompatible data to backup directory..."

            # Stop the test mongod
            mongod --shutdown --port 27018 2>/dev/null || pkill -f "mongod.*27018" || true

            # Create backup directory with timestamp
            BACKUP_DIR="/home/container/mongodb_backup_$(date +%Y%m%d_%H%M%S)"
            mkdir -p "$BACKUP_DIR"

            # Move old data to backup
            mv /home/container/mongodb/* "$BACKUP_DIR/" 2>/dev/null || true

            line GREEN
            msg GREEN "✓ Old MongoDB data safely backed up to: $BACKUP_DIR"
            msg GREEN "✓ Starting fresh MongoDB 8.2 instance"
            msg YELLOW "⚠ Use migration tool to restore your data from backup"
            line GREEN
        else
            # Stop the test mongod if it started successfully
            mongod --shutdown --port 27018 2>/dev/null || pkill -f "mongod.*27018" || true
            line GREEN
            msg GREEN "MongoDB data appears compatible, continuing..."
        fi

        # Clean up test log
        rm -f /tmp/mongo_test.log
    fi
fi

line BLUE
# MongoDB 8.2 compatible startup (removed --logRotate reopen as it's not supported)
mongod --dbpath /home/container/mongodb/ \
       --port 27017 \
       --bind_ip_all \
       --logpath /home/container/mongod.log \
       --logappend &

until nc -z -v -w5 127.0.0.1 27017; do
  echo 'Waiting for MongoDB connection...'
  sleep 5
done


# ----------------------------
# Start Bot
# ----------------------------
line BLUE
msg YELLOW "Starting Bot..."
line BLUE

# ----------------------------
# Startup command
# ----------------------------
MODIFIED_STARTUP=$(echo "${STARTUP}" | sed -e 's/{{/${/g' -e 's/}}/}/g')
msg CYAN ":/home/container$ $MODIFIED_STARTUP"

# exec bash -c für komplexe Shell-Kommandos
eval "$MODIFIED_STARTUP"

# stop mongo
mongod --shutdown
