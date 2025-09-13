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
trap 'echo "$(date "+%Y-%m-%d %H:%M:%S") - Unexpected error at line $LINENO" | tee -a "$ERROR_LOG" >&2' ERR

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
# SteamCMD / DepotDownloader Update
# ----------------------------
if [ -f ./DepotDownloader ]; then
    printf "${BLUE}---------------------------------------------------------------------${NC}\n"
    printf "${YELLOW}Using DepotDownloader for updates${NC}\n"
    printf "${BLUE}---------------------------------------------------------------------${NC}\n"

    : "${STEAM_USER:=anonymous}"  # Default anonymous user
    : "${STEAM_PASS:=}"
    : "${STEAM_AUTH:=}"

    printf "${YELLOW}Steam user: ${GREEN}%s${NC}\n" "$STEAM_USER"

    ./DepotDownloader -dir . \
        -username "$STEAM_USER" \
        -password "$STEAM_PASS" \
        -remember-password \
        $( [ "$WINDOWS_INSTALL" = "1" ] && echo "-os windows" ) \
        -app "$STEAM_APPID" \
        $( [ -n "$STEAM_BETAID" ] && echo "-branch $STEAM_BETAID" ) \
        $( [ -n "$STEAM_BETAPASS" ] && echo "-branchpassword $STEAM_BETAPASS" )

    mkdir -p .steam/sdk64
    ./DepotDownloader -dir .steam/sdk64 \
        $( [ "$WINDOWS_INSTALL" = "1" ] && echo "-os windows" ) \
        -app 1007

    chmod +x "$HOME"/*
else
    printf "${BLUE}---------------------------------------------------------------------${NC}\n"
    printf "${YELLOW}Using SteamCMD for updates${NC}\n"
    printf "${BLUE}---------------------------------------------------------------------${NC}\n"

    : "${STEAM_USER:=anonymous}"  # Default anonymous user
    : "${STEAM_PASS:=}"
    : "${STEAM_AUTH:=}"

    printf "${YELLOW}Steam user: ${GREEN}%s${NC}\n" "$STEAM_USER"

    ./steamcmd/steamcmd.sh +force_install_dir /home/container \
        +login "$STEAM_USER" "$STEAM_PASS" "$STEAM_AUTH" \
        $( [ "$WINDOWS_INSTALL" = "1" ] && echo "+@sSteamCmdForcePlatformType windows" ) \
        $( [ "$STEAM_SDK" = "1" ] && echo "+app_update 1007" ) \
        +app_update "$STEAM_APPID" \
        $( [ -n "$STEAM_BETAID" ] && echo "-beta $STEAM_BETAID" ) \
        $( [ -n "$STEAM_BETAPASS" ] && echo "-betapassword $STEAM_BETAPASS" ) \
        $INSTALL_FLAGS \
        $( [ "$VALIDATE" = "1" ] && echo "validate" ) +quit || \
        printf "${RED}SteamCMD failed!${NC}\n"
fi

# ----------------------------
# Startup command
# ----------------------------
MODIFIED_STARTUP=$(echo "${STARTUP}" | sed -e 's/{{/${/g' -e 's/}}/}/g')
msg CYAN ":/home/container$ $MODIFIED_STARTUP"

# exec bash -c für komplexe Shell-Kommandos
exec bash -c "$MODIFIED_STARTUP"

