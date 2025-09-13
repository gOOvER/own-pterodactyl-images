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

# ----------------------------
# Wine Gecko Installation
# ----------------------------
if [[ $WINETRICKS_RUN =~ gecko ]]; then
    line BLUE
    msg YELLOW "Installing Wine Gecko"
    line BLUE
    WINETRICKS_RUN=$(echo "$WINETRICKS_RUN" | sed 's/\bgecko\b//g')

    # Dynamische Version
    GECKO_VERSION=$(curl -s https://api.github.com/repos/wine-mirror/wine/releases/latest | grep -Po '"tag_name": "\K.*?(?=")' || echo "2.47.4")
    [ ! -f "$WINEPREFIX/gecko_x86.msi" ] && wget -q -O "$WINEPREFIX/gecko_x86.msi" "http://dl.winehq.org/wine/wine-gecko/${GECKO_VERSION:-}/wine_geck${GECKO_VERSION:-}N}-x86.msi"
    [ ! -f "$WINEPREFIX/gecko_x86_64.msi" ] && wget -q -O "$WINEPREFIX/gecko_x86_64.msi" "http://dl.winehq.org/wine/wine-ge${GECKO_VERSION:-}ION}/wine_${GECKO_VERSION:-}RSION}-x86_64.msi"

    wine msiexec /i "$WINEPREFIX/gecko_x86.msi" /qn /quiet /norestart /log "$WINEPREFIX/gecko_x86_install.log" || msg RED "Wine Gecko x86 installation failed!"
    wine msiexec /i "$WINEPREFIX/gecko_x86_64.msi" /qn /quiet /norestart /log "$WINEPREFIX/gecko_x86_64_install.log" || msg RED "Wine Gecko x64 installation failed!"
fi

# ----------------------------
# Wine Mono Installation
# ----------------------------
if [[ "$WINETRICKS_RUN" =~ mono ]]; then
    line BLUE
    msg YELLOW "Installing latest Wine Mono"
    line BLUE
    MONO_VERSION=$(curl -s https://api.github.com/repos/wine-mono/wine-mono/releases/latest | grep -Po '"tag_name": "\K.*?(?=")')
    if [ -z "$MONO_VERSION" ]; then
        msg RED "Failed to fetch latest Wine Mono version."
    else
        MONO_URL="https://github.com/wine-mono/wine-mono/releases/download/${MONO_VERSION}/wine-mono-${MONO_VERSION#wine-mono-}-x86.msi"
        rm -f "$WINEPREFIX/mono.msi"
        wget -q -O "$WINEPREFIX/mono.msi" "$MONO_URL"
        if [ -f "$WINEPREFIX/mono.msi" ]; then
            wine msiexec /i "$WINEPREFIX/mono.msi" /qn /quiet /norestart /log "$WINEPREFIX/mono_install.log" \
                && msg GREEN "Wine Mono installed successfully!" \
                || msg RED "Wine Mono installation failed!"
        else
            msg RED "Failed to download Wine Mono MSI."
        fi
    fi
    WINETRICKS_RUN=$(echo "$WINETRICKS_RUN" | sed 's/\bmono\b//g')
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
    WINETRICKS_RUN=$(echo "$WINETRICKS_RUN" | sed 's/\bvcrun2022\b//g')
fi

# ----------------------------
# Install additional Winetricks packages
# ----------------------------
for trick in $WINETRICKS_RUN; do
    line BLUE
    msg YELLOW "Installing: ${GREEN}$trick"
    line BLUE
    winetricks "$trick" || msg RED "Winetricks installation for $trick failed!"
done

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
    ./steamcmd/steamcmd.sh "${sc_args[@]}" || ${RED:-} "${RED}SteamC${NC:-}iled!${NC}\n"
fi

# ----------------------------
# Startup command
# ----------------------------
MODIFIED_STARTUP=$(echo "${STARTUP}" | sed -e 's/{{/${/g' -e 's/}}/}/g')
msg CYAN ":/home/container$ $MODIFIED_STARTUP"

# exec bash -c für komplexe Shell-Kommandos
exec bash -c "$MODIFIED_STARTUP"

