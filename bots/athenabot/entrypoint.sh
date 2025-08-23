#!/bin/bash
set -e

ERROR_LOG="entrypoint_error.log"
> "$ERROR_LOG"  # Logfile leeren

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

# ----------------------------
# Error trap
# ----------------------------
trap 'echo "$(date +%Y-%m-%d %H:%M:%S) - Unexpected error at line $LINENO" | tee -a "$ERROR_LOG" >&2' ERR

# ----------------------------
# Shutdown handler
# ----------------------------
shutdown_mongo() {
    msg YELLOW "Shutting down MongoDB..."
    mongod --shutdown || msg RED "MongoDB shutdown failed (may not be running)."
}
trap shutdown_mongo SIGTERM SIGINT EXIT

# ----------------------------
# Environment
# ----------------------------
cd /home/container || { msg RED "Failed to change directory to /home/container."; exit 1; }

sleep 1

export TZ=${TZ:-UTC}
export INTERNAL_IP=$(ip route get 1 | awk '{print $(NF-2);exit}')

# ----------------------------
# System Info
# ----------------------------
clear
line BLUE
msg RED "Athena Bot Image by gOOvER - https://discord.goover.dev"
line BLUE
msg YELLOW "Running on: ${RED}$(. /etc/os-release ; echo $NAME $VERSION)"
msg YELLOW "Current timezone: ${RED}$(cat /etc/timezone)"
line BLUE
msg YELLOW "NodeJS Version: ${RED}$(node -v)"
msg YELLOW "npm Version: ${RED}$(npm -v)"
#msg YELLOW "yarn Version: ${RED}$(yarn --version)"
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
mongod --fork --dbpath /home/container/mongodb/ --port 27017 \
       --logpath /home/container/mongod.log --logRotate reopen --logappend

until nc -z -v -w5 127.0.0.1 27017; do
    msg YELLOW "Waiting for MongoDB connection..."
    sleep 5
done

# ----------------------------
# Start AthenaBot
# ----------------------------
line BLUE
msg YELLOW "Starting AthenaBot..."
line BLUE
eval ${MODIFIED_STARTUP}
