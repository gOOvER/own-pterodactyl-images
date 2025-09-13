#!/bin/bash
set -e

ERROR_LOG="install_error.log"
: > "$ERROR_LOG"  # Clear old log file (no-op)

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
    # If RED, also write the message to install_error.log
    if [ "$color" = "RED" ]; then
        printf "%b\n" "${RED}$*${NC}" | tee -a "$ERROR_LOG" >&2
    else
        printf "%b\n" "${!color}$*${NC}"
    fi
}

line() {
    local color="${1:-BLUE}"
    local term_width
    term_width=$(tput cols 2>/dev/null || echo 70)
    local sep
    sep=$(printf '%*s' "$term_width" '' | tr ' ' '-')

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
trap 'echo "$(date +%Y-%m-%d\ %H:%M:%S) - Unexpected error at line $LINENO" | tee -a "$ERROR_LOG" >&2' ERR

# ----------------------------
# System Info
# ----------------------------
LINUX=$(. /etc/os-release; echo "$PRETTY_NAME")
TIMEZONE=$(if [ -f /etc/timezone ]; then cat /etc/timezone; else readlink /etc/localtime | sed 's|.*/zoneinfo/||'; fi)
WINE_VER=$(wine --version 2>/dev/null || echo "Wine not found!")

# ----------------------------
# Banner
# ----------------------------
clear
line BLUE
msg YELLOW "Wine Image from gOOvER"
msg RED "THIS IMAGE IS LICENSED UNDER AGPLv3"
line BLUE
msg YELLOW "Docker Linux Distribution: ${RED}$LINUX"
msg YELLOW "Current timezone: ${RED}$TIMEZONE"
msg YELLOW "Wine Version: ${RED}$WINE_VER"
line BLUE

# ----------------------------
# Environment
# ----------------------------
export TZ=${TZ:-UTC}
internal_ip=$(ip route get 1 | awk '{print $(NF-2);exit}' 2>/dev/null || echo "127.0.0.1")
export INTERNAL_IP="$internal_ip"
export XDG_RUNTIME_DIR="/home/container/.config/xdg"
mkdir -p "$XDG_RUNTIME_DIR"

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

    dd_args=( -dir . -username "$STEAM_USER" -password "$STEAM_PASS" -remember-password )
    if [ "${WINDOWS_INSTALL:-0}" = "1" ]; then
        dd_args+=( -os windows )
    fi
    dd_args+=( -app "$STEAM_APPID" )
    if [ -n "${STEAM_BETAID:-}" ]; then
        dd_args+=( -branch "$STEAM_BETAID" )
    fi
    if [ -n "${STEAM_BETAPASS:-}" ]; then
        dd_args+=( -branchpassword "$STEAM_BETAPASS" )
    fi
    ./DepotDownloader "${dd_args[@]}"

    mkdir -p .steam/sdk64
    dd_sdk_args=( -dir .steam/sdk64 -app 1007 )
    if [ "${WINDOWS_INSTALL:-0}" = "1" ]; then
        dd_sdk_args+=( -os windows )
    fi
    ./DepotDownloader "${dd_sdk_args[@]}"

    chmod +x "$HOME"/*
else
    printf "${BLUE}---------------------------------------------------------------------${NC}\n"
    printf "${YELLOW}Using SteamCMD for updates${NC}\n"
    printf "${BLUE}---------------------------------------------------------------------${NC}\n"

    : "${STEAM_USER:=anonymous}"  # Default anonymous user
    : "${STEAM_PASS:=}"
    : "${STEAM_AUTH:=}"

    printf "${YELLOW}Steam user: ${GREEN}%s${NC}\n" "$STEAM_USER"

    sc_args=( +force_install_dir /home/container +login "$STEAM_USER" "$STEAM_PASS" "$STEAM_AUTH" )
    if [ "${WINDOWS_INSTALL:-0}" = "1" ]; then
        sc_args+=( +@sSteamCmdForcePlatformType windows )
    fi
    if [ "${STEAM_SDK:-0}" = "1" ]; then
        sc_args+=( +app_update 1007 )
    fi
    sc_args+=( +app_update "$STEAM_APPID" )
    if [ -n "${STEAM_BETAID:-}" ]; then
        sc_args+=( -beta "$STEAM_BETAID" )
    fi
    if [ -n "${STEAM_BETAPASS:-}" ]; then
        sc_args+=( -betapassword "$STEAM_BETAPASS" )
    fi
    if [ -n "${INSTALL_FLAGS:-}" ]; then
        IFS=' ' read -r -a extra_flags <<<"$INSTALL_FLAGS"
        sc_args+=( "${extra_flags[@]}" )
    fi
    if [ "${VALIDATE:-0}" = "1" ]; then
        sc_args+=( validate )
    fi
    sc_args+=( +quit )
    ./steamcmd/steamcmd.sh "${sc_args[@]}" || printf "${RED:-}SteamCMD faile${NC:-}C}\n"
fi


# ----------------------------
# Startup command
# ----------------------------

MODIFIED_STARTUP=$(echo "${STARTUP}" | sed -e 's/{{/${/g' -e 's/}}/}/g')
msg CYAN ":/home/container$ $MODIFIED_STARTUP"

# exec bash -c für komplexe Shell-Kommandos
exec bash -c "$MODIFIED_STARTUP"

