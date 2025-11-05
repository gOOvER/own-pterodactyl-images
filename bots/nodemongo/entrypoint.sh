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
# MongoDB 8.2 Container Configuration
storage:
  dbPath: /home/container/mongodb
  engine: wiredTiger
  wiredTiger:
    engineConfig:
      cacheSizeGB: 0.25

systemLog:
  destination: file
  path: /home/container/mongod.log
  logAppend: true

net:
  port: 27017
  bindIp: 127.0.0.1

processManagement:
  fork: false
  pidFilePath: /home/container/mongodb/mongod.pid

security:
  authorization: disabled
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

    # Start MongoDB 8.2 - container optimized approach
    msg CYAN "Attempting to start MongoDB 8.2..."
    
    # Method 1: Background process without fork for containers
    if mongod --config /home/container/mongodb/mongod.conf > /home/container/mongod.startup.log 2>&1 &
    then
        MONGOD_PID=$!
        echo "$MONGOD_PID" > /home/container/mongodb/mongod.pid
        msg GREEN "MongoDB started in background (PID: $MONGOD_PID)"
        sleep 3  # Give MongoDB time to initialize
    else
        msg RED "Failed to start MongoDB. Check startup log:"
        if [ -f /home/container/mongod.startup.log ]; then
            tail -20 /home/container/mongod.startup.log | tee -a "$ERROR_LOG"
        fi
        exit 1
    fi
fi

# Wait for MongoDB to be ready
MONGO_WAIT_COUNT=0
until nc -z -v -w5 127.0.0.1 27017 2>/dev/null; do
    MONGO_WAIT_COUNT=$((MONGO_WAIT_COUNT + 1))
    if [ $MONGO_WAIT_COUNT -gt 20 ]; then  # 100 seconds timeout for container startup
        msg RED "MongoDB failed to start within 100 seconds"
        
        # Check if MongoDB process is still running
        if [ -f /home/container/mongodb/mongod.pid ]; then
            MONGOD_PID=$(cat /home/container/mongodb/mongod.pid)
            if ! kill -0 "$MONGOD_PID" 2>/dev/null; then
                msg RED "MongoDB process died. Check logs:"
                if [ -f /home/container/mongod.log ]; then
                    tail -30 /home/container/mongod.log | tee -a "$ERROR_LOG"
                fi
                if [ -f /home/container/mongod.startup.log ]; then
                    msg RED "Startup log:"
                    cat /home/container/mongod.startup.log | tee -a "$ERROR_LOG"
                fi
                exit 1
            fi
        fi
        
        msg RED "MongoDB seems to be running but not accepting connections"
        if [ -f /home/container/mongod.log ]; then
            msg RED "MongoDB log output:"
            tail -30 /home/container/mongod.log | tee -a "$ERROR_LOG"
        fi
        exit 1
    fi
    msg YELLOW "Waiting for MongoDB connection... (${MONGO_WAIT_COUNT}/20)"
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
