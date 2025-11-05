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
    # Stop MongoDB if we started it
    if pgrep mongod > /dev/null; then
        msg YELLOW "Stopping MongoDB..."
        mongod --dbpath /home/container/mongodb/ --shutdown || pkill mongod || true
    fi
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
# Startup Command
# ----------------------------
MODIFIED_STARTUP=$(echo -e "$(echo -e "${STARTUP}" | sed -e 's/{{/${/g' -e 's/}}/}/g')")
msg YELLOW ":/home/container ${RED}${MODIFIED_STARTUP}"

# ----------------------------
# Start MongoDB
# ----------------------------
line BLUE
msg YELLOW "Starting MongoDB..."
line BLUE

# Ensure MongoDB directory exists and has correct permissions
mkdir -p /home/container/mongodb
chown -R container:container /home/container/mongodb 2>/dev/null || true

# Create minimal MongoDB configuration file for MongoDB 8.2
cat > /home/container/mongodb/mongod.conf << 'EOF'
# Minimal MongoDB 8.2 configuration
storage:
  dbPath: /home/container/mongodb

systemLog:
  destination: file
  path: /home/container/mongod.log

net:
  port: 27017
  bindIp: 127.0.0.1

processManagement:
  fork: true
EOF

# Check if MongoDB is already running
if pgrep mongod > /dev/null; then
    msg GREEN "MongoDB is already running"
else
    # Kill any stale lock files
    rm -f /home/container/mongodb/mongod.lock

    # Get MongoDB version for logging
    MONGO_VERSION=$(mongod --version | head -n 1 | grep -oE '[0-9]+\.[0-9]+' | head -1)
    msg CYAN "Using MongoDB version: $MONGO_VERSION"

    # Start MongoDB 8.2 - try different approaches
    msg CYAN "Attempting to start MongoDB 8.2..."
    
    # Method 1: Try with config file and --nojournal
    if mongod --config /home/container/mongodb/mongod.conf --nojournal 2>/dev/null; then
        msg GREEN "MongoDB started successfully (config + --nojournal)"
    # Method 2: Try with config file only
    elif mongod --config /home/container/mongodb/mongod.conf 2>/dev/null; then
        msg GREEN "MongoDB started successfully (config only)"
    # Method 3: Try minimal command line only
    elif mongod --fork --dbpath /home/container/mongodb/ --port 27017 \
                --logpath /home/container/mongod.log --bind_ip 127.0.0.1 2>/dev/null; then
        msg GREEN "MongoDB started successfully (minimal command line)"
    else
        msg RED "Failed to start MongoDB with all methods. Check log:"
        if [ -f /home/container/mongod.log ]; then
            tail -20 /home/container/mongod.log | tee -a "$ERROR_LOG"
        fi
        exit 1
    fi
fi

# Wait for MongoDB to be ready
MONGO_WAIT_COUNT=0
until nc -z -v -w5 127.0.0.1 27017; do
    MONGO_WAIT_COUNT=$((MONGO_WAIT_COUNT + 1))
    if [ $MONGO_WAIT_COUNT -gt 12 ]; then  # 60 seconds timeout
        msg RED "MongoDB failed to start within 60 seconds"
        if [ -f /home/container/mongod.log ]; then
            msg RED "MongoDB log output:"
            tail -20 /home/container/mongod.log | tee -a "$ERROR_LOG"
        fi
        exit 1
    fi
    msg YELLOW "Waiting for MongoDB connection... (${MONGO_WAIT_COUNT}/12)"
    sleep 5
done

msg GREEN "MongoDB is ready!"

# ----------------------------
# Start Bot
# ----------------------------
line BLUE
msg YELLOW "Starting Bot..."
line BLUE

# Validate startup command
if [ -z "$MODIFIED_STARTUP" ]; then
    msg RED "STARTUP command is empty!"
    exit 1
fi

msg CYAN "Executing: $MODIFIED_STARTUP"
exec bash -lc "$MODIFIED_STARTUP"
