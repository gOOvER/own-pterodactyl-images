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
    if [ -f /home/container/mongodb/mongod.pid ]; then
        MONGOD_PID=$(cat /home/container/mongodb/mongod.pid)
        if kill -0 "$MONGOD_PID" 2>/dev/null; then
            msg YELLOW "Stopping MongoDB (PID: $MONGOD_PID)..."
            kill "$MONGOD_PID" 2>/dev/null || true
            rm -f /home/container/mongodb/mongod.pid
        fi
    elif pgrep mongod > /dev/null; then
        msg YELLOW "Stopping MongoDB..."
        pkill mongod || true
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

# Create MongoDB configuration file optimized for containers (MongoDB 8.2)
cat > /home/container/mongodb/mongod.conf << 'EOF'
# MongoDB 8.2 Container Configuration - Minimal & Robust
storage:
  dbPath: /home/container/mongodb

systemLog:
  destination: file
  path: /home/container/mongod.log
  logAppend: true
  quiet: true

net:
  port: 27017
  bindIp: 127.0.0.1

processManagement:
  fork: false

# Disable problematic features for containers
setParameter:
  disabledSecureAllocatorDomains: "*"
EOF

# Check if MongoDB is already running and accessible
if nc -z -v -w2 127.0.0.1 27017 2>/dev/null; then
    msg GREEN "MongoDB is already running and accessible!"
else
    # Kill any stale lock files and processes
    rm -f /home/container/mongodb/mongod.lock
    rm -f /home/container/mongodb/mongod.pid
    pkill mongod 2>/dev/null || true
    sleep 2

    # Get MongoDB version for logging
    MONGO_VERSION=$(mongod --version | head -n 1 | grep -oE '[0-9]+\.[0-9]+' | head -1)
    msg CYAN "Using MongoDB version: $MONGO_VERSION"

    # Start MongoDB 8.2 - simplified direct approach
    msg CYAN "Starting MongoDB 8.2..."
    
    # Start MongoDB in background using simple command line (avoid config issues)
    mongod --dbpath /home/container/mongodb \
           --logpath /home/container/mongod.log \
           --port 27017 \
           --bind_ip 127.0.0.1 \
           --quiet \
           --logappend > /dev/null 2>&1 &
    
    MONGOD_PID=$!
    echo "$MONGOD_PID" > /home/container/mongodb/mongod.pid
    msg GREEN "MongoDB started in background (PID: $MONGOD_PID)"
    
    # Brief wait for MongoDB to initialize
    sleep 5
    
    # Quick connection test (only 3 attempts)
    for i in 1 2 3; do
        if nc -z -w2 127.0.0.1 27017 2>/dev/null; then
            msg GREEN "MongoDB is ready!"
            break
        fi
        if [ $i -eq 3 ]; then
            msg YELLOW "MongoDB may still be starting up (this is normal for first run)"
            break
        fi
        sleep 2
    done
fi

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
