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
# Startup Command
# ----------------------------
MODIFIED_STARTUP=$(echo -e "$(echo -e "${STARTUP}" | sed -e 's/{{/${/g' -e 's/}}/}/g')")
msg YELLOW ":/home/container ${RED}${MODIFIED_STARTUP}"

# ----------------------------
# Start MongoDB
# ----------------------------
echo -e "${BLUE}---------------------------------------------------------------------${NC}"
echo -e "${YELLOW}starting MongoDB...${NC}"
echo -e "${BLUE}---------------------------------------------------------------------${NC}"

# Ensure MongoDB directory exists and has correct permissions
mkdir -p /home/container/mongodb
chown -R container:container /home/container/mongodb 2>/dev/null || true

# MongoDB 8.2 compatible startup (removed --logRotate reopen as it's not supported)
mongod --fork --dbpath /home/container/mongodb/ --port 27017 --logpath /home/container/mongod.log --logappend && until nc -z -v -w5 127.0.0.1 27017; do echo 'Waiting for mongodb connection...'; sleep 5; done

# ----------------------------
# Start Bot
# ----------------------------
echo -e "${BLUE}---------------------------------------------------------------------${NC}"
echo -e "${YELLOW}starting Bot...${NC}"
echo -e "${BLUE}---------------------------------------------------------------------${NC}"

# Set MongoDB connection environment variables for the bot
export MONGO_URL="mongodb://127.0.0.1:27017"
export MONGODB_URI="mongodb://127.0.0.1:27017"
export DB_HOST="127.0.0.1"
export DB_PORT="27017"

eval ${MODIFIED_STARTUP}

# stop mongo
mongod --shutdown
