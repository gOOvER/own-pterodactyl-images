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

# Rotate/compress large logs to avoid unbounded growth
rotate_log() {
    local logfile="$1"
    local max_bytes=${2:-5242880} # default 5 MiB
    local keep=${3:-3}
    if [ -z "$logfile" ]; then
        return 0
    fi
    if [ -f "$logfile" ]; then
        local size
        size=$(stat -c%s "$logfile" 2>/dev/null || wc -c <"$logfile" 2>/dev/null || echo 0)
        if [ "$size" -ge "$max_bytes" ]; then
            local ts
            ts=$(date +%s)
            local archive="${logfile}.${ts}.gz"
            msg YELLOW "Rotating large log $logfile -> $archive (size=${size})"
            # move then compress to avoid holding both uncompressed on disk
            if mv "$logfile" "${logfile}.${ts}" 2>/dev/null; then
                if command -v gzip &>/dev/null; then
                    gzip -9 "${logfile}.${ts}" && msg YELLOW "Compressed rotated log to ${archive}"
                else
                    msg YELLOW "gzip not available; leaving rotated file uncompressed: ${logfile}.${ts}"
                fi
            else
                # fallback: truncate the file to avoid disk full
                : > "$logfile"
                msg YELLOW "Failed to rotate; truncated $logfile"
            fi
            # optionally clean up old archives
            if command -v ls &>/dev/null; then
                local files
                files=$(ls -1t ${logfile}.*.gz 2>/dev/null || true)
                if [ -n "$files" ]; then
                    local idx=0
                    for f in $files; do
                        idx=$((idx+1))
                        if [ $idx -gt $keep ]; then
                            rm -f "$f" || true
                            msg YELLOW "Removed old rotated log $f"
                        fi
                    done
                fi
            fi
        fi
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
# Ensure a sane default WINEPREFIX and export it so wine/winetricks use it
export WINEPREFIX="${WINEPREFIX:-/home/container/.wine}"
# Default to 64-bit Wine prefixes unless explicitly overridden
export WINEARCH="${WINEARCH:-win64}"
# Ensure X virtual framebuffer is always enabled for winetricks GUI needs
export XVFB=1
# Default DISPLAY and screen geometry
export DISPLAY="${DISPLAY:-:0}"
export DISPLAY_WIDTH="${DISPLAY_WIDTH:-1024}"
export DISPLAY_HEIGHT="${DISPLAY_HEIGHT:-768}"
export DISPLAY_DEPTH="${DISPLAY_DEPTH:-24}"

# Rotate any existing large logs at startup to avoid immediate disk blowup
rotate_log "$WINEPREFIX/dotnet_direct_install.log" 5242880 3 || true
rotate_log "$WINEPREFIX/mono_install.log" 5242880 3 || true
rotate_log "$WINEPREFIX/wineboot_init.log" 5242880 3 || true
rotate_log "$WINEPREFIX/install_error.log" 5242880 3 || true

# ----------------------------
# Required tools check
# ----------------------------
for tool in wget wine cabextract Xvfb xdpyinfo; do
    if ! command -v "$tool" &>/dev/null; then
        msg RED "Error: Required tool '$tool' is not installed."
        exit 1
    fi
done

cd /home/container || { msg RED "Failed to change directory to /home/container."; exit 1; }

# ----------------------------
# Xvfb (always enabled)
# ----------------------------
mkdir -p "$WINEPREFIX/logs"
XVFB_LOG="$WINEPREFIX/logs/xvfb.log"
# If an X server is already available on $DISPLAY, don't start a new one
if ! xdpyinfo -display "$DISPLAY" &>/dev/null; then
    msg YELLOW "Starting Xvfb on $DISPLAY (${DISPLAY_WIDTH}x${DISPLAY_HEIGHT}x${DISPLAY_DEPTH})"
    Xvfb "$DISPLAY" -screen 0 ${DISPLAY_WIDTH}x${DISPLAY_HEIGHT}x${DISPLAY_DEPTH} &> "$XVFB_LOG" &
    XVFB_PID=$!
    sleep 1
    if ! kill -0 "$XVFB_PID" 2>/dev/null; then
        msg RED "Xvfb failed to start; check $XVFB_LOG"
        exit 1
    fi
    msg GREEN "Xvfb started (pid $XVFB_PID), log: $XVFB_LOG"
    # Ensure Xvfb is killed on exit
    trap 'if [ -n "${XVFB_PID:-}" ] && kill -0 "$XVFB_PID" 2>/dev/null; then kill "$XVFB_PID" || true; fi' EXIT
else
    msg YELLOW "Display $DISPLAY already available; not starting Xvfb"
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

# NOTE: 64-bit is the default (WINEARCH=win64). No automatic 32-bit enforcement is performed.

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
        exit 1
    fi
    if [ -s "$WINEPREFIX/gecko_x86_64.msi" ]; then
        wine msiexec /i "$WINEPREFIX/gecko_x86_64.msi" /qn /norestart /log "$WINEPREFIX/gecko_x86_64_install.log" || msg RED "Wine Gecko x64 installation failed! See $WINEPREFIX/gecko_x86_64_install.log"
    else
        msg RED "Gecko x64 MSI missing or empty: $WINEPREFIX/gecko_x86_64.msi"
        exit 1
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
                    exit 1
            fi
        fi
    fi
    WINETRICKS_RUN=$(remove_token_from_list "$WINETRICKS_RUN" mono)
fi

# ----------------------------
# vcrun2022 via winetricks
# ----------------------------
if [[ "$WINETRICKS_RUN" =~ vcrun2022 ]]; then
    line BLUE
    msg YELLOW "Installing vcrun2022 via winetricks"
    line BLUE
    mkdir -p "$WINEPREFIX/logs"
    VCRUN_LOG="$WINEPREFIX/logs/winetricks-vcrun2022.log"
    rotate_log "$VCRUN_LOG" 5242880 5 || true
    if winetricks -q vcrun2022 &> "$VCRUN_LOG"; then
        msg GREEN "vcrun2022 installed via winetricks (log: $VCRUN_LOG)"
    else
        # If winetricks returned non-zero (cabextract warnings etc.) but the
        # actual runtime DLLs exist in the prefix, allow startup to continue.
        msg YELLOW "winetricks vcrun2022 returned non-zero; verifying required DLLs..."
        missing_dll=0
        for dll in msvcp140.dll vcruntime140.dll; do
            if [ -f "$WINEPREFIX/drive_c/windows/system32/$dll" ] || [ -f "$WINEPREFIX/drive_c/windows/syswow64/$dll" ]; then
                msg YELLOW "Found $dll in prefix"
            else
                msg RED "Missing $dll in prefix"
                missing_dll=1
            fi
        done
        if [ "$missing_dll" -eq 0 ]; then
            msg GREEN "Required vcrun2022 DLLs present; continuing despite winetricks warnings. (See $VCRUN_LOG for details)"
        else
            msg RED "winetricks vcrun2022 failed and required DLLs are missing; see $VCRUN_LOG"
            exit 1
        fi
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
            rotate_log "$LOGFILE" 5242880 5 || true
                # Special-case diagnostics and fallbacks for dotnet installers
                if [[ "$trick" =~ dotnet ]]; then
                    msg YELLOW "Detected dotnet trick: running winetricks for diagnostics"
                    # Choose WINEDEBUG level: full 'all' only when DEBUG_DOTNET=1 is set by user
                    WINEDEBUG_LEVEL=${DEBUG_DOTNET:-0}
                    if [ "$WINEDEBUG_LEVEL" -eq 1 ]; then
                        DBG_ENV="WINEDEBUG=all"
                    else
                        DBG_ENV="WINEDEBUG=warn"
                    fi
                    # First try non-interactive winetricks with chosen debug level
                    if eval "$DBG_ENV winetricks -q \"$trick\" &> \"$LOGFILE\""; then
                        msg GREEN "Winetricks: $trick installed successfully (log: $LOGFILE)"
                    else
                        msg YELLOW "Winetricks failed for $trick; attempting direct installer from winetricks cache"
                        CACHE_DIR="/home/container/.cache/winetricks/$trick"
                        INSTALLER=""
                        if [ -d "$CACHE_DIR" ]; then
                            INSTALLER=$(ls -1 "$CACHE_DIR"/*.exe 2>/dev/null | tail -n1 || true)
                        fi
                        if [ -n "$INSTALLER" ]; then
                            DIRECT_LOG="$WINEPREFIX/dotnet_direct_install.log"
                            # Use stricter rotation/truncation for direct dotnet logs (1 MiB)
                            rotate_log "$DIRECT_LOG" 1048576 5 || true
                            msg YELLOW "Found cached installer: $INSTALLER — attempting direct wine execution"
                            # Choose debug env for direct installer as well
                            if [ "$WINEDEBUG_LEVEL" -eq 1 ]; then
                                DIRECT_DBG_ENV="WINEDEBUG=all"
                            else
                                DIRECT_DBG_ENV="WINEDEBUG=warn"
                            fi
                            # Try quiet install first
                            if eval "$DIRECT_DBG_ENV wine \"$INSTALLER\" /quiet &>> \"$DIRECT_LOG\""; then
                                msg GREEN "Direct dotnet installer (/quiet) succeeded (log: $DIRECT_LOG)"
                            else
                                msg YELLOW "Direct dotnet installer (/quiet) failed, trying interactive run (no /quiet)"
                                if eval "$DIRECT_DBG_ENV wine \"$INSTALLER\" &>> \"$DIRECT_LOG\""; then
                                    msg GREEN "Direct dotnet installer (interactive) succeeded (log: $DIRECT_LOG)"
                                else
                                    msg RED "Direct dotnet installer failed; see $DIRECT_LOG and $LOGFILE for details"
                                    # Truncate direct log to last 2000 lines to avoid giant files
                                    tail -n 2000 "$DIRECT_LOG" > "${DIRECT_LOG}.tmp" && mv "${DIRECT_LOG}.tmp" "$DIRECT_LOG" || true
                                    exit 1
                                fi
                            fi
                        else
                            msg RED "No cached dotnet installer found in $CACHE_DIR. See $LOGFILE for winetricks details."
                            exit 1
                        fi
                    fi
                else
                    # Try a non-interactive install where supported (-q), fall back if not
                    if winetricks -q "$trick" &> "$LOGFILE"; then
                        msg GREEN "Winetricks: $trick installed successfully (log: $LOGFILE)"
                    else
                        # Try without -q in case the option is not supported
                        if winetricks "$trick" &>> "$LOGFILE"; then
                            msg GREEN "Winetricks: $trick installed successfully (log: $LOGFILE)"
                        else
                            msg RED "Winetricks installation for $trick failed! See $LOGFILE"
                            exit 1
                        fi
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

