#!/bin/bash
# Steam Proton-GE Entrypoint for Pelican/Pterodactyl
# Licensed under AGPLv3

set -euo pipefail

# --- Non-interactive for apt ---
export DEBIAN_FRONTEND=noninteractive

# --- Steam directories ---
export STEAM_DIR="$HOME/.steam/steam"
export STEAM_COMPAT_CLIENT_INSTALL_PATH="$STEAM_DIR"
export STEAM_COMPAT_DATA_PATH="$STEAM_DIR/steamapps/compatdata/${STEAM_APPID:-}"
export WINEPREFIX="$STEAM_COMPAT_DATA_PATH/pfx"
export PROTON_HOME="$HOME/.protonGE"
mkdir -p "$PROTON_HOME" "$WINEPREFIX"

# --- XDG runtime dir in Steam folder ---
export XDG_RUNTIME_DIR="$STEAM_DIR/.config/xdg"
mkdir -p "$XDG_RUNTIME_DIR"

# --- User-local binaries ---
export PATH="$HOME/.local/bin:$PATH"

# --- Proton / Wine paths ---
export WINE="$PROTON_HOME/dist/bin/wine"
export WINE64="$PROTON_HOME/dist/bin/wine64"
export WINETRICKS="$HOME/.local/bin/winetricks"
export PROTONTRICKS_BIN="$HOME/.local/bin/protontricks"
export PROTONFIX_DIR="$STEAM_DIR/.config/protonfixes"
mkdir -p "$PROTONFIX_DIR"

# --- Colors ---
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
NC=$(tput sgr0)
LINE="${BLUE}----------------------------------------------------------------${NC}"

# --- Logging functions ---
log_info()    { echo "${BLUE}[INFO]${NC} $*"; }
log_warn()    { echo "${YELLOW}[WARN]${NC} $*"; }
log_error()   { echo "${RED}[ERROR]${NC} $*" >&2; }
log_success() { echo "${GREEN}[ OK ]${NC} $*"; }

# --- Safe command execution ---
run_or_fail() {
    local desc="$1"; shift
    if "$@"; then
        log_success "$desc"
    else
        log_error "$desc failed!"
        exit 1
    fi
}

# --- Protontricks installation ---
install_protontricks() {
    if [ -z "${PROTONTRICKS_RUN:-}" ]; then
        log_info "No Protontricks specified. Skipping."
        return
    fi
    echo -e "$LINE"
    log_info "Starting Protontricks installation for AppID ${STEAM_APPID}"
    echo -e "$LINE"
    for trick in $PROTONTRICKS_RUN; do
        log_info "Installing Protontrick: ${trick}"
        if "$PROTONTRICKS_BIN" --unattended "${STEAM_APPID}" "$trick"; then
            log_success "Protontrick installed: ${trick}"
        else
            log_warn "Protontrick failed: ${trick} (continuing...)"
        fi
    done
    echo -e "$LINE"
    log_info "Finished Protontricks installation"
    echo -e "$LINE"
}

# --- Winecfg if prefix doesn't exist ---
run_winecfg() {
    if [ "${WINECFG_RUN:-0}" == "1" ]; then
        if [ ! -d "$WINEPREFIX" ]; then
            echo -e "$LINE"
            log_info "Initializing new Wineprefix and running winecfg for AppID ${STEAM_APPID}"
            echo -e "$LINE"
            run_or_fail "winecfg" "$WINE"
        else
            log_info "Wineprefix already exists at $WINEPREFIX, skipping winecfg."
        fi
    fi
}

# --- Wait for container startup ---
sleep 1

# --- Set timezone ---
export TZ=${TZ:-UTC}

# --- Internal IP ---
INTERNAL_IP=$(ip route get 1 | awk '{print $(NF-2);exit}')
export INTERNAL_IP

# --- System info ---
clear
echo -e "$LINE"
log_info "Proton-GE Image | goover.dev | Licensed under AGPLv3"
echo -e "$LINE"
log_info "Linux: $(. /etc/os-release; echo $PRETTY_NAME)"
log_info "Kernel: $(uname -r)"
log_info "Timezone: $TZ"
log_info "Proton Version: $(cat $PROTON_HOME/version 2>/dev/null || echo 'Unknown')"
echo -e "$LINE"

# --- Check Steam AppID ---
if [ -z "${STEAM_APPID:-}" ]; then
    echo -e "$LINE"
    log_error "Missing STEAM_APPID! Proton cannot run without it."
    echo -e "$LINE"
    exit 1
fi

# --- Auto-update ---
if [ -z "${AUTO_UPDATE:-}" ] || [ "${AUTO_UPDATE}" == "1" ]; then
    if [ -f "$HOME/DepotDownloader" ]; then
        run_or_fail "Updating game via DepotDownloader" \
            ./DepotDownloader -dir "$HOME" \
            -username "${STEAM_USER:-anonymous}" -password "${STEAM_PASS:-}" -remember-password \
            $( [[ "${WINDOWS_INSTALL:-0}" == "1" ]] && printf %s '-os windows' ) \
            -app "${STEAM_APPID}" \
            $( [[ -n "${STEAM_BETAID:-}" ]] && printf %s "-branch ${STEAM_BETAID}" ) \
            $( [[ -n "${STEAM_BETAPASS:-}" ]] && printf %s "-branchpassword ${STEAM_BETAPASS}" )

        mkdir -p "$STEAM_DIR/sdk64"
        ./DepotDownloader -dir "$STEAM_DIR/sdk64" \
            $( [[ "${WINDOWS_INSTALL:-0}" == "1" ]] && printf %s '-os windows' ) -app 1007
        chmod +x "$HOME"/*
    else
        run_or_fail "Updating game via SteamCMD" \
            ./steamcmd/steamcmd.sh +force_install_dir "$HOME" \
            +login "${STEAM_USER:-anonymous}" "${STEAM_PASS:-}" "${STEAM_AUTH:-}" \
            $( [[ "${WINDOWS_INSTALL:-0}" == "1" ]] && printf %s '+@sSteamCmdForcePlatformType windows' ) \
            $( [[ "${STEAM_SDK:-0}" == "1" ]] && printf %s '+app_update 1007' ) \
            +app_update "${STEAM_APPID}" \
            $( [[ -n "${STEAM_BETAID:-}" ]] && printf %s "-beta ${STEAM_BETAID}" ) \
            $( [[ -n "${STEAM_BETAPASS:-}" ]] && printf %s "-betapassword ${STEAM_BETAPASS}" ) \
            ${INSTALL_FLAGS:-} \
            $( [[ "${VALIDATE:-0}" == "1" ]] && printf %s 'validate' ) +quit
    fi
else
    log_info "Auto update disabled (AUTO_UPDATE=0), skipping update."
fi

# --- Run Protontricks if requested ---
install_protontricks

# --- Run winecfg if requested ---
run_winecfg

# --- Start Xvfb only if XVFB=1 ---
if [ "${XVFB:-0}" == "1" ]; then
    export DISPLAY=:1
    Xvfb $DISPLAY -screen 0 1024x768x24 +extension RANDR &
    XVFB_PID=$!
    trap "log_info 'Stopping Xvfb...'; kill $XVFB_PID" EXIT
    log_info "Xvfb started on display $DISPLAY (PID $XVFB_PID)"
else
    log_info "XVFB not enabled, skipping virtual framebuffer."
fi

echo -e "$LINE"
log_info "Starting server..."
echo -e "$LINE"

# --- Replace Pelican variables in STARTUP ---
MODIFIED_STARTUP=$(echo -e "${STARTUP}" | sed -e 's/{{/${/g' -e 's/}}/}/g')
echo -e ":$HOME$ ${MODIFIED_STARTUP}"

# --- Run server ---
exec bash -c "${MODIFIED_STARTUP}"
