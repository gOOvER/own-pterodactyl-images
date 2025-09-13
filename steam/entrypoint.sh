#!/bin/bash
set -e

ERROR_LOG="install_error.log"
> "$ERROR_LOG"  # Clear old log file

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
    # If RED, also write to install_error.log
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
# Error trap for uncaught errors
# ----------------------------
trap 'echo "$(date +%Y-%m-%d %H:%M:%S) - Unexpected error at line $LINENO" | tee -a "$ERROR_LOG" >&2' ERR

# ----------------------------
# System Info
# ----------------------------
LINUX=$(. /etc/os-release; echo "$PRETTY_NAME")
TIMEZONE=$(if [ -f /etc/timezone ]; then cat /etc/timezone; else readlink /etc/localtime | sed 's|.*/zoneinfo/||'; fi)
PROTON_VER=$(cat /usr/local/bin/version 2>/dev/null || echo "Unknown")

# ----------------------------
# Banner
# ----------------------------
clear
line BLUE
msg RED "SteamCMD Proton-GE Image by gOOvER - https://discord.goover.dev"
msg RED "THIS IMAGE IS LICENSED UNDER AGPLv3"
line BLUE
msg YELLOW "Linux Distribution: ${RED}$LINUX"
msg YELLOW "Kernel: ${RED}$(uname -r)"
msg YELLOW "Current timezone: ${RED}$TIMEZONE"
msg YELLOW "Proton Version: ${RED}$PROTON_VER"
line BLUE

# ----------------------------
# Set environment for Steam Proton
# ----------------------------
if [ -n "${STEAM_APPID}" ]; then
    mkdir -p /home/container/.steam/steam/steamapps/compatdata/${STEAM_APPID}
    export STEAM_COMPAT_CLIENT_INSTALL_PATH="/home/container/.steam/steam"
    export STEAM_COMPAT_DATA_PATH="/home/container/.steam/steam/steamapps/compatdata/${STEAM_APPID}"
    export WINETRICKS="/usr/sbin/winetricks"
    export STEAM_DIR="/home/container/.steam/steam/"
else
    line BLUE
    msg RED "WARNING!!! Proton needs variable STEAM_APPID, else it will not work. Please add it."
    msg RED "Server stops now."
    line BLUE
    exit 0
fi

sleep 2

# ----------------------------
# Switch to the container's working directory
# ----------------------------
cd /home/container || exit 1

# ----------------------------
# Steam user check
# ----------------------------
if [ -z "${STEAM_USER}" ]; then
    line BLUE
    msg YELLOW "Steam user is not set."
    msg YELLOW "Using anonymous user."
    line BLUE
    STEAM_USER="anonymous"
    STEAM_PASS=""
    STEAM_AUTH=""
else
    line BLUE
    msg YELLOW "User set to ${STEAM_USER}"
    line BLUE
fi

# ----------------------------
# Update/Download
# ----------------------------
if [ -z "${AUTO_UPDATE}" ] || [ "${AUTO_UPDATE}" == "1" ]; then
    if [ -f /home/container/DepotDownloader ]; then
        ./DepotDownloader -dir /home/container \
            -username "${STEAM_USER}" \
            -password "${STEAM_PASS}" \
            -remember-password \
            $( [[ "${WINDOWS_INSTALL}" == "1" ]] && printf %s '-os windows' ) \
            -app "${STEAM_APPID}" \
            $( [[ -n "${STEAM_BETAID}" ]] && printf %s "-branch ${STEAM_BETAID}" ) \
            $( [[ -n "${STEAM_BETAPASS}" ]] && printf %s "-branchpassword ${STEAM_BETAPASS}" )
        mkdir -p /home/container/.steam/sdk64
        ./DepotDownloader -dir /home/container/.steam/sdk64 \
            $( [[ "${WINDOWS_INSTALL}" == "1" ]] && printf %s '-os windows' ) \
            -app 1007
        chmod +x $HOME/*
    else
        ./steamcmd/steamcmd.sh +force_install_dir /home/container \
            +login "${STEAM_USER}" "${STEAM_PASS}" "${STEAM_AUTH}" \
            $( [[ "${WINDOWS_INSTALL}" == "1" ]] && printf %s '+@sSteamCmdForcePlatformType windows' ) \
            $( [[ "${STEAM_SDK}" == "1" ]] && printf %s '+app_update 1007' ) \
            +app_update "${STEAM_APPID}" \
            $( [[ -n "${STEAM_BETAID}" ]] && printf %s "-beta ${STEAM_BETAID}" ) \
            $( [[ -n "${STEAM_BETAPASS}" ]] && printf %s "-betapassword ${STEAM_BETAPASS}" ) \
            ${INSTALL_FLAGS} \
            $( [[ "${VALIDATE}" == "1" ]] && printf %s 'validate' ) +quit
    fi
else
    line BLUE
    msg YELLOW "Not updating game server as auto update was set to 0. Starting Server."
    line BLUE
fi

line BLUE
msg GREEN "Starting Server.... Please wait..."
line BLUE

# ----------------------------
# Protontricks support
# ----------------------------
if [ -n "${PROTONTRICKS_RUN}" ]; then
    for trick in $PROTONTRICKS_RUN; do
        line BLUE
        msg YELLOW "Protontricks: Installing ${trick}"
        line BLUE
        protontricks "${STEAM_APPID}" "${trick}" || msg RED "Protontricks for ${trick} failed!"
    done
fi

# ----------------------------
# Replace Startup Variables and run server
# ----------------------------
MODIFIED_STARTUP=$(echo -e "${STARTUP}" | sed -e 's/{{/${/g' -e 's/}}/}/g')
msg CYAN ":/home/container$ ${MODIFIED_STARTUP}"
eval "${MODIFIED_STARTUP}"
