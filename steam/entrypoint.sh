#!/bin/bash
set -euo pipefail

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

# Robust Proton version detection. We try several locations in order:
# 1) /opt/ProtonGE/version
# 2) /usr/local/share/steam/compatibilitytools.d/ProtonGE/version
# 3) run `proton --version` if a wrapper/binary exists
# 4) fallback: inspect extracted folder names like GE-Proton* under /opt or compatibilitytools.d
PROTON_VER="Unknown"
if [ -f /opt/ProtonGE/version ]; then
    PROTON_VER=$(cat /opt/ProtonGE/version 2>/dev/null || echo "Unknown")
fi
if [ "$PROTON_VER" = "Unknown" ] && [ -f /usr/local/share/steam/compatibilitytools.d/ProtonGE/version ]; then
    PROTON_VER=$(cat /usr/local/share/steam/compatibilitytools.d/ProtonGE/version 2>/dev/null || echo "Unknown")
fi
if [ "$PROTON_VER" = "Unknown" ] && command -v proton >/dev/null 2>&1; then
    # Some proton wrappers accept --version; capture first non-empty line
    PROTON_VER=$(proton --version 2>/dev/null | head -n1 || true)
    # normalize empty to Unknown
    if [ -z "${PROTON_VER:-}" ]; then
        PROTON_VER="Unknown"
    fi
fi
if [ "$PROTON_VER" = "Unknown" ]; then
    # Try to infer from folder names under /opt or compatibilitytools.d
    DIRNAME=$(find /opt -maxdepth 1 -type d -name 'GE-Proton*' -printf '%f\n' 2>/dev/null | head -n1 || true)
    if [ -n "$DIRNAME" ]; then
        PROTON_VER="$DIRNAME"
    else
        DIRNAME=$(find /usr/local/share/steam/compatibilitytools.d -maxdepth 1 -type d -name 'GE-Proton*' -printf '%f\n' 2>/dev/null | head -n1 || true)
        if [ -n "$DIRNAME" ]; then
            PROTON_VER="$DIRNAME"
        fi
    fi
fi

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
    # Ensure all Steam/Proton directories live under /home/container/Steam
    # Create canonical steam directory and compatdata path
	mkdir -p /home/container/Steam
    mkdir -p /home/container/Steam/steamapps/compatdata/${STEAM_APPID}
    mkdir -p /home/container/Steam/compatibilitytools.d

	export STEAM_DIR="/home/container/Steam"
	export STEAM_COMPAT_CLIENT_INSTALL_PATH="$STEAM_DIR"
    export STEAM_COMPAT_DATA_PATH="$STEAM_COMPAT_CLIENT_INSTALL_PATH/steamapps/compatdata/${STEAM_APPID}"
    export WINETRICKS="/usr/sbin/winetricks"

    # Set WINEPREFIX to the per-App compatibilityprefix derived from STEAM_DIR (non-destructive).
    if [ -z "${WINEPREFIX:-}" ]; then
        WINEPREFIX="$STEAM_DIR/steamapps/compatdata/${STEAM_APPID}/pfx"
        # Ensure the parent and prefix directories exist (non-destructive)
        mkdir -p "${WINEPREFIX%/pfx}" 2>/dev/null || true
        mkdir -p "$WINEPREFIX" 2>/dev/null || true
        export WINEPREFIX
        msg GREEN "WINEPREFIX set to $WINEPREFIX"

        # Ensure XDG_CONFIG_HOME is defined and protonfixes config directory exists.
        # ProtonFixes expects "$HOME/.config/protonfixes" by default; create it
        # here so ProtonFixes doesn't abort with a missing parent directory.
        if [ -z "${XDG_CONFIG_HOME:-}" ]; then
            export XDG_CONFIG_HOME="$HOME/.config"
        fi
        # Create parent and protonfixes dir if absent. Be tolerant for root/non-root users.
        mkdir -p "$XDG_CONFIG_HOME/protonfixes" 2>/dev/null || true
        # Ensure basic permissions so the runtime user can write to it.
        chmod 700 "$XDG_CONFIG_HOME" 2>/dev/null || true
        chmod 700 "$XDG_CONFIG_HOME/protonfixes" 2>/dev/null || true
    fi

    # If ProtonGE is installed system-wide under /opt/ProtonGE, create a
    # non-destructive symlink into the per-container compatibilitytools.d
    # so tools like protontricks can find it without duplicating content.
    if [ -d "/opt/ProtonGE" ]; then
        TARGET_DIR="$STEAM_COMPAT_CLIENT_INSTALL_PATH/compatibilitytools.d"
        TARGET_LINK="$TARGET_DIR/ProtonGE"
        if [ ! -e "$TARGET_LINK" ]; then
            mkdir -p "$TARGET_DIR"
            if ln -s /opt/ProtonGE "$TARGET_LINK" 2>/dev/null; then
                msg GREEN "Created symlink: $TARGET_LINK -> /opt/ProtonGE"
            else
                msg RED "Failed to create symlink $TARGET_LINK -> /opt/ProtonGE"
            fi
        else
            if [ -L "$TARGET_LINK" ]; then
                # If it's already a symlink, check whether it points to the same source.
                EXIST_SRC=$(readlink -f "$TARGET_LINK" || true)
                if [ "$EXIST_SRC" != "/opt/ProtonGE" ]; then
                    msg YELLOW "Existing symlink $TARGET_LINK points to $EXIST_SRC; not modifying."
                fi
            else
                # Target exists and is not a symlink (file/dir) — do not overwrite.
                msg YELLOW "Target $TARGET_LINK already exists and is not a symlink; skipping symlink creation to avoid data loss."
            fi
        fi
    fi
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

is_valid_steam_dir() {
    # Consider a Steam dir valid if it contains any strong Steam markers:
    # - steam.sh or steam (client binary)
    # - steamapps/libraryfolders.vdf (library descriptor)
    # - steamapps (basic steamapps layout)
    # - compatibilitytools.d (for Proton compatibility tools)
    local dir="$1"
    # Check for Steam runtime folder 'ubuntu12_32' in a few common locations
    RUNTIME_FOUND=0
    if [ -d "$dir/ubuntu12_32" ] || [ -d "$dir/.steam/root/ubuntu12_32" ] || [ -d "$HOME/.steam/root/ubuntu12_32" ]; then
        RUNTIME_FOUND=1
    fi

    if [ -f "$dir/steam.sh" ] || [ -x "$dir/steam" ]; then
        if [ "$RUNTIME_FOUND" -eq 1 ]; then
            msg GREEN "Detected Steam dir: $dir (found steam.sh/steam binary and runtime)"
            return 0
        else
            msg YELLOW "Found steam.sh/steam binary in $dir but runtime folder 'ubuntu12_32' not found; continuing checks"
        fi
    fi
    # Accept both 'steamapps' and 'SteamApps' directories and different casings
    if [ -f "$dir/steamapps/libraryfolders.vdf" ] || [ -f "$dir/SteamApps/libraryfolders.vdf" ] || [ -f "$dir/steamapps/LibraryFolders.vdf" ] || [ -f "$dir/SteamApps/LibraryFolders.vdf" ]; then
        if [ "$RUNTIME_FOUND" -eq 1 ]; then
            msg GREEN "Detected Steam dir: $dir (found libraryfolders.vdf/LibraryFolders.vdf and runtime)"
            return 0
        else
            msg YELLOW "Found libraryfolders.vdf in $dir but runtime folder 'ubuntu12_32' not found; continuing checks"
        fi
    fi
    if [ -d "$dir/steamapps" ] || [ -d "$dir/SteamApps" ]; then
        if [ "$RUNTIME_FOUND" -eq 1 ]; then
            msg GREEN "Detected Steam dir: $dir (contains steamapps/ or SteamApps/ and runtime)"
            return 0
        else
            msg YELLOW "Found steamapps/ in $dir but runtime folder 'ubuntu12_32' not found; continuing checks"
        fi
    fi
    if [ -d "$dir/compatibilitytools.d" ]; then
        msg GREEN "Detected Steam dir: $dir (contains compatibilitytools.d/)"
        return 0
    fi
    return 1
}

if [ -n "${PROTONTRICKS_RUN:-}" ]; then
    # protontricks support has been removed from this image. The build no longer
    # installs or exposes protontricks. If you need to run winetricks-like
    # actions, run them manually on your host or in a different image that
    # includes protontricks. We intentionally do not attempt any automatic
    # installations here to avoid surprising changes to user prefixes.
    msg YELLOW "PROTONTRICKS_RUN is set but protontricks support has been removed from this image; skipping."
fi

# ----------------------------
# Winetricks runtime installation (into the per-app WINEPREFIX)
# ----------------------------
# Use `WINETRICKS_RUN` to install runtimes or verbs into the WINEPREFIX.
# Example: WINETRICKS_RUN="vcrun2015 corefonts" and optional
# `WINETRICKS_OPTS` for winetricks flags (e.g. --no-isolate --force).
if [ -n "${WINETRICKS_RUN:-}" ]; then
    # Default location for winetricks binary (can be overridden by env)
    WINETRICKS=${WINETRICKS:-/usr/sbin/winetricks}

    if [ -z "${WINEPREFIX:-}" ]; then
        msg RED "WINETRICKS_RUN is set but WINEPREFIX is empty; cannot run winetricks"
    else
        line BLUE
        msg YELLOW "Preparing to run winetricks into WINEPREFIX=${GREEN}${WINEPREFIX}${NC}"
        line BLUE

        # Ensure prefix directories exist (non-destructive)
        mkdir -p "${WINEPREFIX%/pfx}" 2>/dev/null || true
        mkdir -p "$WINEPREFIX" 2>/dev/null || true

        if command -v "$WINETRICKS" >/dev/null 2>&1; then
            # Show intended actions
            msg YELLOW "winetricks actions: ${GREEN}$WINETRICKS_RUN${NC}"

            # Run winetricks with optional options. We intentionally allow
            # the shell to split $WINETRICKS_RUN into separate verbs so
            # multiple verbs can be passed in one invocation.
            if [ -n "${WINETRICKS_OPTS:-}" ]; then
                msg YELLOW "Running: WINEPREFIX=${WINEPREFIX} $WINETRICKS $WINETRICKS_OPTS $WINETRICKS_RUN"
                env WINEPREFIX="$WINEPREFIX" "$WINETRICKS" $WINETRICKS_OPTS $WINETRICKS_RUN || msg RED "winetricks failed"
            else
                msg YELLOW "Running: WINEPREFIX=${WINEPREFIX} $WINETRICKS $WINETRICKS_RUN"
                env WINEPREFIX="$WINEPREFIX" "$WINETRICKS" $WINETRICKS_RUN || msg RED "winetricks failed"
            fi
        else
            msg RED "winetricks not found at ${WINETRICKS}; cannot install runtimes"
        fi
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