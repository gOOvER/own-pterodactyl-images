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

# Helper: remove a token (word) from a space-separated list variable
remove_token_from_list() {
    local var_value="$1"
    local token="$2"
    local out=""
    read -r -a parts <<<"$var_value"
    for p in "${parts[@]}"; do
        if [ "$p" != "$token" ]; then
            out="${out}${out:+ }${p}"
        fi
    done
    printf '%s' "$out"
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
# Required tools check
# ----------------------------
for tool in wget wine cabextract; do
    if ! command -v "$tool" &>/dev/null; then
        msg RED "Error: Required tool '$tool' is not installed."
        exit 1
    fi
done

cd /home/container || { msg RED "Failed to change directory to /home/container."; exit 1; }

# ----------------------------
# Xvfb
# ----------------------------
if [[ $XVFB == 1 ]]; then
    Xvfb :0 -screen 0 ${DISPLAY_WIDTH:-1024}x${DISPLAY_HEIGHT:-768}x${DISPLAY_DEPTH:-24} &
    sleep 2
fi

# ----------------------------
# Wine setup
# ----------------------------
line BLUE
msg RED "Setting up Wine... Please wait..."
line BLUE

mkdir -p "$WINEPREFIX"
if [ ! -d "$WINEPREFIX/drive_c" ]; then
    wineboot --init || { msg RED "wineboot failed!"; exit 1; }
fi

# Auto-detect common 32-bit installers (like dotnet) and enforce a 32-bit WINEPREFIX
if echo " ${WINETRICKS_RUN:-} " | grep -qE '\bdotnet\b|\bdotnet7\b|\bdotnet-runtime\b'; then
    if [ "${WINEARCH:-}" != "win32" ]; then
        msg YELLOW "Detected 32-bit dotnet installer requested; enforcing 32-bit WINEPREFIX (WINEARCH=win32)."
        export FORCE_WINEARCH=win32
        export WINEARCH=win32
        # If an existing prefix exists, back it up to avoid data loss
        if [ -d "$WINEPREFIX" ] && [ "$(ls -A "$WINEPREFIX" 2>/dev/null)" != "" ]; then
            BACKUP_PREFIX="${WINEPREFIX}-backup-$(date +%s)"
            msg YELLOW "Backing up existing WINEPREFIX to $BACKUP_PREFIX"
            mv "$WINEPREFIX" "$BACKUP_PREFIX" || msg RED "Failed to backup existing WINEPREFIX"
        fi
        rm -rf "$WINEPREFIX"
        mkdir -p "$WINEPREFIX"
        # create a fresh 32-bit prefix
        WINEDEBUG=all wineboot --init &>/dev/null || msg YELLOW "wineboot returned non-zero while creating 32-bit prefix (this may be okay)."
        msg GREEN "Created new 32-bit WINEPREFIX at $WINEPREFIX"
    else
        msg YELLOW "dotnet install requested and WINEARCH already set to win32."
    fi
fi

# ----------------------------
# Wine Gecko Installation
# ----------------------------
if [[ $WINETRICKS_RUN =~ gecko ]]; then
    line BLUE
    msg YELLOW "Installing Wine Gecko"
    line BLUE
    WINETRICKS_RUN=$(remove_token_from_list "$WINETRICKS_RUN" gecko)

    # Dynamische Version
    GECKO_VERSION=$(curl -s https://api.github.com/repos/wine-mirror/wine/releases/latest | grep -Po '"tag_name": "\K.*?(?=")' || echo "2.47.4")
    GECKO_BASE="https://dl.winehq.org/wine/wine-gecko/${GECKO_VERSION}"
    GECKO_X86="$GECKO_BASE/wine-gecko-${GECKO_VERSION}-x86.msi"
    GECKO_X64="$GECKO_BASE/wine-gecko-${GECKO_VERSION}-x86_64.msi"

    # download with retries and size check
    mkdir -p "$WINEPREFIX"
    if [ ! -s "$WINEPREFIX/gecko_x86.msi" ]; then
        msg YELLOW "Downloading Gecko x86 from ${GECKO_X86}"
        if ! wget -q --tries=3 --timeout=30 -O "$WINEPREFIX/gecko_x86.msi" "$GECKO_X86"; then
            msg RED "Failed to download Gecko x86 from $GECKO_X86"
        fi
    fi
    if [ ! -s "$WINEPREFIX/gecko_x86_64.msi" ]; then
        msg YELLOW "Downloading Gecko x64 from ${GECKO_X64}"
        if ! wget -q --tries=3 --timeout=30 -O "$WINEPREFIX/gecko_x86_64.msi" "$GECKO_X64"; then
            msg RED "Failed to download Gecko x64 from $GECKO_X64"
        fi
    fi

    # verify files and install
    if [ -s "$WINEPREFIX/gecko_x86.msi" ]; then
        wine msiexec /i "$WINEPREFIX/gecko_x86.msi" /qn /norestart /log "$WINEPREFIX/gecko_x86_install.log" || msg RED "Wine Gecko x86 installation failed! See $WINEPREFIX/gecko_x86_install.log"
    else
        msg RED "Gecko x86 MSI missing or empty: $WINEPREFIX/gecko_x86.msi"
    fi
    if [ -s "$WINEPREFIX/gecko_x86_64.msi" ]; then
        wine msiexec /i "$WINEPREFIX/gecko_x86_64.msi" /qn /norestart /log "$WINEPREFIX/gecko_x86_64_install.log" || msg RED "Wine Gecko x64 installation failed! See $WINEPREFIX/gecko_x86_64_install.log"
    else
        msg RED "Gecko x64 MSI missing or empty: $WINEPREFIX/gecko_x86_64.msi"
    fi
fi

# ----------------------------
# Wine Mono Installation
# ----------------------------
if [[ "$WINETRICKS_RUN" =~ mono ]]; then
    line BLUE
    msg YELLOW "Installing latest Wine Mono"
    line BLUE
    # Optionally force WINEARCH (e.g. win32) via env FORCE_WINEARCH=win32
    if [ -n "${FORCE_WINEARCH:-}" ]; then
        export WINEARCH="${FORCE_WINEARCH}"
        msg YELLOW "Forcing WINEARCH=$WINEARCH"
        # recreate prefix if necessary
        if [ ! -d "$WINEPREFIX" ]; then
            wineboot --init || true
        fi
    fi

    MONO_VERSION=$(curl -s https://api.github.com/repos/wine-mono/wine-mono/releases/latest | grep -Po '"tag_name": "\K.*?(?=")')
    if [ -z "$MONO_VERSION" ]; then
        msg RED "Failed to fetch latest Wine Mono version."
    else
        MONO_URL="https://github.com/wine-mono/wine-mono/releases/download/${MONO_VERSION}/wine-mono-${MONO_VERSION#wine-mono-}-x86.msi"
        rm -f "$WINEPREFIX/mono.msi"
        msg YELLOW "Downloading Wine Mono from $MONO_URL"
        if ! wget -q --tries=3 --timeout=30 -O "$WINEPREFIX/mono.msi" "$MONO_URL"; then
            msg RED "Failed to download Wine Mono MSI from $MONO_URL"
        else
            # install with retries and logging
            attempts=0
            max_attempts=3
            rc=1
            while [ $attempts -lt $max_attempts ]; do
                attempts=$((attempts+1))
                msg YELLOW "Attempt $attempts to install Wine Mono..."
                if wine msiexec /i "$WINEPREFIX/mono.msi" /qn /norestart /log "$WINEPREFIX/mono_install.log"; then
                    rc=0
                    msg GREEN "Wine Mono installed successfully on attempt $attempts"
                    break
                else
                    msg YELLOW "Wine Mono installer failed on attempt $attempts (see $WINEPREFIX/mono_install.log)"
                    sleep 3
                fi
            done
            if [ $rc -ne 0 ]; then
                msg RED "Wine Mono installation failed after $max_attempts attempts. See $WINEPREFIX/mono_install.log"
            fi
        fi
    fi
    WINETRICKS_RUN=$(remove_token_from_list "$WINETRICKS_RUN" mono)
fi

# ----------------------------
# vcrun2022 64bit DLL extraction
# ----------------------------
if [[ "$WINETRICKS_RUN" =~ vcrun2022 ]]; then
    line BLUE
    msg YELLOW "Downloading vcrun2022 (Visual C++ Redistributable 2022, 64bit)"
    line BLUE
    VCRUN_URL="https://aka.ms/vs/17/release/vc_redist.x64.exe"
    VCRUN_FILE="$WINEPREFIX/vc_redist.x64.exe"
    DLL_DEST="$WINEPREFIX/drive_c/windows/system32"

    rm -f "$VCRUN_FILE"
    wget -q -O "$VCRUN_FILE" "$VCRUN_URL"
    if [ -f "$VCRUN_FILE" ]; then
        msg YELLOW "Extracting DLLs from installer..."
        mkdir -p "$DLL_DEST"
        cabextract -d "$DLL_DEST" "$VCRUN_FILE" || { msg RED "cabextract failed!"; exit 1; }
        DLLS=("msvcp140.dll" "vcruntime140.dll")
        for dll in "${DLLS[@]}"; do
            if [ -f "$DLL_DEST/$dll" ]; then
                msg GREEN "$dll successfully extracted to system32."
            else
                msg RED "$dll not found after extraction."
            fi
        done
    else
        msg RED "Failed to download vcrun2022 x64."
    fi
    WINETRICKS_RUN=$(remove_token_from_list "$WINETRICKS_RUN" vcrun2022)
fi

# ----------------------------
# Install additional Winetricks packages (robust)
# ----------------------------
# Ensure WINETRICKS_RUN is not empty and trim whitespace
if [ -n "${WINETRICKS_RUN// }" ]; then
    # Ensure winetricks command exists
    if ! command -v winetricks &>/dev/null; then
        msg RED "winetricks not found but WINETRICKS_RUN is set. Please install winetricks or unset WINETRICKS_RUN."
    else
        # Split into array on whitespace (preserves quoted args if any)
        read -r -a _tricks <<<"$WINETRICKS_RUN"
        for trick in "${_tricks[@]}"; do
            line BLUE
            msg YELLOW "Installing: ${GREEN}$trick"
            line BLUE
            mkdir -p "$WINEPREFIX/logs"
            LOGFILE="$WINEPREFIX/logs/winetricks-${trick//[^a-zA-Z0-9_.-]/_}.log"
            # Try a non-interactive install where supported (-q), fall back if not
            if winetricks -q "$trick" &> "$LOGFILE"; then
                msg GREEN "Winetricks: $trick installed successfully (log: $LOGFILE)"
            else
                # Try without -q in case the option is not supported
                if winetricks "$trick" &>> "$LOGFILE"; then
                    msg GREEN "Winetricks: $trick installed successfully (log: $LOGFILE)"
                else
                    msg RED "Winetricks installation for $trick failed! See $LOGFILE"
                fi
            fi
        done
    fi
fi

# ----------------------------
# SteamCMD / DepotDownloader Update
# ----------------------------
if [ -z "${STEAM_APPID:-}" ] && [ -n "${SRCDS_APPID:-}" ]; then
    STEAM_APPID="$SRCDS_APPID"
fi
if [ -f ./DepotDownloader ]; then
    line BLUE
    msg YELLOW "Using DepotDownloader for updates"
    line BLUE

    : "${STEAM_USER:=anonymous}"  # Default anonymous user
    : "${STEAM_PASS:=}"
    : "${STEAM_AUTH:=}"

    msg YELLOW "Steam user: ${GREEN}$STEAM_USER${NC}"

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
    line BLUE
    msg YELLOW "Using SteamCMD for updates"
    line BLUE

    : "${STEAM_USER:=anonymous}"  # Default anonymous user
    : "${STEAM_PASS:=}"
    : "${STEAM_AUTH:=}"

    msg YELLOW "Steam user: ${GREEN}$STEAM_USER${NC}"

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
    if ! ./steamcmd/steamcmd.sh "${sc_args[@]}"; then
        msg RED "SteamCMD failed!"
    fi
fi

# ----------------------------
# Startup command
# ----------------------------
MODIFIED_STARTUP=$(echo "${STARTUP}" | sed -e 's/{{/${/g' -e 's/}}/}/g')
msg CYAN ":/home/container$ $MODIFIED_STARTUP"

# exec bash -c für komplexe Shell-Kommandos
exec bash -c "$MODIFIED_STARTUP"

