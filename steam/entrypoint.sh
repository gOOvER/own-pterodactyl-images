#!/bin/bash
set -euo pipefail

ERROR_LOG="install_error.log"
: > "$ERROR_LOG"  # Clear old log file (no-op)

#!/bin/bash
set -e

ERROR_LOG="install_error.log"
: > "$ERROR_LOG"  # Alte Logdatei leeren (no-op)

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
    # Wenn ROT, zusätzlich in install_error.log schreiben
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
# Print timestamp, failing command and line number
# ----------------------------
# initialize rc so static checkers do not warn about unassigned var
rc=0
trap 'rc=$?; echo "$(date "+%Y-%m-%d %H:%M:%S") - Unexpected error (exit $rc) at line $LINENO: \"${BASH_COMMAND}\"" | tee -a "$ERROR_LOG" >&2; exit $rc' ERR

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
# Ensure a sane XDG_RUNTIME_DIR for services that rely on it
if [ -z "${XDG_RUNTIME_DIR:-}" ]; then
    export XDG_RUNTIME_DIR="/tmp/xdg-runtime-dir"
    mkdir -p "$XDG_RUNTIME_DIR"
    chown 1000:1000 "$XDG_RUNTIME_DIR" 2>/dev/null || true
fi

# Ensure HOME is set
HOME=${HOME:-/home/container}

if [ -n "${STEAM_APPID:-}" ]; then
    # Ensure all Steam/Proton directories live under /home/container/steam
    # Create canonical steam directory and compatdata path
    mkdir -p /home/container/steam/steamapps/compatdata/${STEAM_APPID}
    mkdir -p /home/container/steam/compatibilitytools.d

    # ProtonGE is available system-wide; no per-user copy is required

    # Determine a valid STEAM_DIR. Prefer system-installed Steam, then the
    # user's ~/.steam/steam, then the local /home/container/steam layout.
    if [ -d "/usr/local/share/steam" ] && [ -d "/usr/local/share/steam/steamapps" ]; then
        export STEAM_DIR="/usr/local/share/steam"
    elif [ -d "/home/container/.steam/steam" ] && [ -d "/home/container/.steam/steam/steamapps" ]; then
        export STEAM_DIR="/home/container/.steam/steam"
    else
        # Fall back to the local /home/container/steam directory we created.
        export STEAM_DIR="/home/container/steam"
    fi

    export STEAM_COMPAT_CLIENT_INSTALL_PATH="$STEAM_DIR"
    export STEAM_COMPAT_DATA_PATH="$STEAM_COMPAT_CLIENT_INSTALL_PATH/steamapps/compatdata/${STEAM_APPID}"
    export WINETRICKS="/usr/sbin/winetricks"
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
cd /home/container || { msg RED "Cannot cd to /home/container"; exit 1; }

# ----------------------------
# Steam user check
# ----------------------------
if [ -z "${STEAM_USER:-}" ]; then
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
    line BLUE
    msg YELLOW "Using DepotDownloader for updates"
    line BLUE

    : "${STEAM_USER:=anonymous}"  # Default anonymous user
    : "${STEAM_PASS:=}"
    : "${STEAM_AUTH:=}"

    printf "${YELLOW}Steam user: ${GREEN}%s${NC}\n" "$STEAM_USER"

    if ! command -v mono >/dev/null 2>&1 && file ./DepotDownloader | grep -qi 'PE32'; then
        msg YELLOW "DepotDownloader looks like a .NET app; ensure 'mono' is available or it is executable"
    fi

    # Build DepotDownloader arguments safely to avoid word-splitting
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

    chmod +x "$HOME"/* || true
else
    line BLUE
    msg YELLOW "Using SteamCMD for updates"
    line BLUE

    : "${STEAM_USER:=anonymous}"  # Default anonymous user
    : "${STEAM_PASS:=}"
    : "${STEAM_AUTH:=}"

    printf "${YELLOW}Steam user: ${GREEN}%s${NC}\n" "$STEAM_USER"

    if [ ! -x ./steamcmd/steamcmd.sh ]; then
        msg RED "steamcmd not found or not executable at ./steamcmd/steamcmd.sh"
    else
            # Build steamcmd arguments safely
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
            # Split INSTALL_FLAGS into array if set (simple whitespace split)
            if [ -n "${INSTALL_FLAGS:-}" ]; then
                # shellcheck disable=SC2206
                IFS=' ' read -r -a extra_flags <<<"$INSTALL_FLAGS"
                sc_args+=( "${extra_flags[@]}" )
            fi
            if [ "${VALIDATE:-0}" = "1" ]; then
                sc_args+=( validate )
            fi
            sc_args+=( +quit )

            ./steamcmd/steamcmd.sh "${sc_args[@]}" || printf "${RED:-}SteamCMD faile${NC:-}C}\n"
    fi
fi

# ----------------------------
# Protontricks package installation
# ----------------------------
# Use PROTONTRICKS_RUN to install packages via `protontricks` if provided.
# Example: PROTONTRICKS_RUN="vcrun2015 corefonts" (space-separated list)
is_valid_steam_dir() {
    # Consider a Steam dir valid if it contains steamapps or compatibilitytools.d
    [ -d "$1/steamapps" ] || [ -d "$1/compatibilitytools.d" ]
}

if [ -n "${PROTONTRICKS_RUN:-}" ]; then
    if [ -z "${STEAM_APPID:-}" ]; then
        msg RED "PROTONTRICKS_RUN is set but STEAM_APPID is empty; skipping protontricks installations"
    else
        # PROTONTRICKS_OPTS can contain options that must be placed before <APPID>
        # Example: PROTONTRICKS_OPTS="--no-gui --another-flag"
        if ! is_valid_steam_dir "$STEAM_DIR"; then
            msg RED "STEAM_DIR='$STEAM_DIR' does not look like a valid Steam installation; skipping protontricks installations"
            # skip the protontricks block entirely
            PROTONTRICKS_RUN=""
        fi
        for trick in $PROTONTRICKS_RUN; do
            line BLUE
            msg YELLOW "Installing for AppID ${GREEN}$STEAM_APPID${NC}: ${GREEN}$trick"
            line BLUE
            if command -v protontricks >/dev/null 2>&1; then
                # Use eval-like array splitting: run protontricks $PROTONTRICKS_OPTS <APPID> <ACTIONS>
                # We rely on the shell to split $trick into separate args if it contains multiple actions.
                if [ -n "${PROTONTRICKS_OPTS:-}" ]; then
                    protontricks $PROTONTRICKS_OPTS "$STEAM_APPID" $trick || msg RED "Protontricks installation for $trick failed!"
                else
                    protontricks "$STEAM_APPID" $trick || msg RED "Protontricks installation for $trick failed!"
                fi
            else
                msg RED "protontricks not found in PATH; cannot install $trick"
                break
            fi
        done
    fi
fi

# ----------------------------
# Startup command
# ----------------------------
if [ -z "${STARTUP:-}" ]; then
    msg RED "No STARTUP command provided; nothing to exec. Exiting."
    exit 1
fi

MODIFIED_STARTUP=$(echo "${STARTUP}" | sed -e 's/{{/${/g' -e 's/}}/}/g')
msg CYAN ":/home/container$ $MODIFIED_STARTUP"

# Use exec to replace shell with the startup command. Quote carefully.
exec bash -lc "$MODIFIED_STARTUP"



