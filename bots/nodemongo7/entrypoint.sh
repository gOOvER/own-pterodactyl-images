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
msg RED "NodeJS & MongoDB 7.x Image by gOOvER - https://discord.goover.dev"
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
# Start MongoDB 7.x
# ----------------------------
line BLUE
msg YELLOW "Starting MongoDB 7.x..."
line BLUE

# Ensure MongoDB directory exists and has correct permissions
mkdir -p /home/container/mongodb
chown -R container:container /home/container/mongodb 2>/dev/null || true

# Check for existing MongoDB data and ensure compatibility
if [ -f "/home/container/mongodb/_mdb_catalog.wt" ] || [ -f "/home/container/mongodb/WiredTiger.wt" ]; then
    line YELLOW
    msg YELLOW "Existing MongoDB data detected - checking compatibility..."

    # MongoDB 7.x can handle most previous versions better than 8.x
    # Simple compatibility check for very old data formats
    if [ -f "/home/container/mongodb/storage.bson" ]; then
        line CYAN
        msg YELLOW "Checking MongoDB 7.x data compatibility..."

        # Quick test startup to verify data integrity
        mongod --dbpath /home/container/mongodb/ --port 27018 --logpath /tmp/mongo_test.log --fork 2>/dev/null || true
        sleep 2

        # Check for major compatibility issues
        if grep -q "corrupted\|invalid.*format\|unsupported.*version" /tmp/mongo_test.log 2>/dev/null; then
            line RED
            msg RED "WARNING: MongoDB data may be corrupted or from unsupported version!"
            line RED
            msg YELLOW "Consider backing up data before proceeding."
            msg YELLOW "If problems persist, use migration tools or restore from backup."
            line YELLOW

            # Stop the test mongod
            mongod --shutdown --port 27018 2>/dev/null || pkill -f "mongod.*27018" || true

            # Create backup directory with timestamp
            BACKUP_DIR="/home/container/mongodb_backup_$(date +%Y%m%d_%H%M%S)"
            mkdir -p "$BACKUP_DIR"

            # Move problematic data to backup
            mv /home/container/mongodb/* "$BACKUP_DIR/" 2>/dev/null || true

            line GREEN
            msg GREEN "✓ Problematic data backed up to: $BACKUP_DIR"
            msg GREEN "✓ Starting fresh MongoDB 7.x instance"
            line GREEN
        else
            # Stop the test mongod if it started successfully
            mongod --shutdown --port 27018 2>/dev/null || pkill -f "mongod.*27018" || true
            line GREEN
            msg GREEN "MongoDB 7.x data appears compatible, continuing..."
        fi

        # Clean up test log
        rm -f /tmp/mongo_test.log
    else
        line GREEN
        msg GREEN "MongoDB data directory detected, proceeding with 7.x startup..."
    fi
fi

line BLUE
# MongoDB 7.x compatible startup with logRotate support
mongod --dbpath /home/container/mongodb/ \
       --port 27017 \
       --bind_ip_all \
       --logpath /home/container/mongod.log \
       --logappend \
       --logRotate reopen &

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
exec bash -c "$MODIFIED_STARTUP"

# stop mongo
mongod --shutdown
