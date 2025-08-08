#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'
export XDG_RUNTIME_DIR="/home/container/.config/xdg"
mkdir -p "$XDG_RUNTIME_DIR"

# Get Linux distribution name
LINUX=$(. /etc/os-release ; echo $PRETTY_NAME)
TZ=${TZ:-UTC}
export TZ

# Welcome and system info
clear
printf "${BLUE}---------------------------------------------------------------------${NC}\n"
printf "${YELLOW}Wine Image from gOOvER${NC}\n"
printf "${RED}THIS IMAGE IS LICENSED UNDER AGPLv3${NC}\n"
printf "${BLUE}---------------------------------------------------------------------${NC}\n"
printf "${YELLOW}Docker Linux Distribution: ${RED}%s${NC}\n" "$LINUX"
printf "${YELLOW}Current timezone: %s${NC}\n" "$(cat /etc/timezone)"
printf "${YELLOW}Wine Version: ${RED}%s${NC}\n" "$(wine --version)"
printf "${BLUE}---------------------------------------------------------------------${NC}\n"

# Get internal IP address
INTERNAL_IP=$(ip route get 1 | awk '{print $(NF-2);exit}')
export INTERNAL_IP

cd /home/container || exit 1

# Start Xvfb if needed
if [[ $XVFB == 1 ]]; then
    Xvfb :0 -screen 0 ${DISPLAY_WIDTH}x${DISPLAY_HEIGHT}x${DISPLAY_DEPTH} &
fi

# Create WINEPREFIX directory
printf "${BLUE}---------------------------------------------------------------------${NC}\n"
printf "${RED}Setting up Wine... Please wait...${NC}\n"
printf "${BLUE}---------------------------------------------------------------------${NC}\n"
mkdir -p "$WINEPREFIX"
#wineboot --init

# Install Wine Gecko if requested
if [[ $WINETRICKS_RUN =~ gecko ]]; then
    printf "${BLUE}---------------------------------------------------------------------${NC}\n"
    printf "${YELLOW}Installing Wine Gecko${NC}\n"
    printf "${BLUE}---------------------------------------------------------------------${NC}\n"
    WINETRICKS_RUN=${WINETRICKS_RUN/gecko}
    [ ! -f "$WINEPREFIX/gecko_x86.msi" ] && wget -q -O "$WINEPREFIX/gecko_x86.msi" http://dl.winehq.org/wine/wine-gecko/2.47.4/wine_gecko-2.47.4-x86.msi
    [ ! -f "$WINEPREFIX/gecko_x86_64.msi" ] && wget -q -O "$WINEPREFIX/gecko_x86_64.msi" http://dl.winehq.org/wine/wine-gecko/2.47.4/wine_gecko-2.47.4-x86_64.msi
    wine msiexec /i "$WINEPREFIX/gecko_x86.msi" /qn /quiet /norestart /log "$WINEPREFIX/gecko_x86_install.log"
    wine msiexec /i "$WINEPREFIX/gecko_x86_64.msi" /qn /quiet /norestart /log "$WINEPREFIX/gecko_x86_64_install.log"
fi

# Install Wine Mono if requested
if [[ "$WINETRICKS_RUN" =~ mono ]]; then
    printf "${BLUE}---------------------------------------------------------------------${NC}\n"
    printf "${YELLOW}Installing latest Wine Mono${NC}\n"
    printf "${BLUE}---------------------------------------------------------------------${NC}\n"
    MONO_VERSION=$(curl -s https://api.github.com/repos/wine-mono/wine-mono/releases/latest | grep -Po '"tag_name": "\K.*?(?=")')
    if [ -z "$MONO_VERSION" ]; then
        printf "${RED}Failed to fetch latest Wine Mono version.${NC}\n"
    else
        MONO_URL="https://github.com/wine-mono/wine-mono/releases/download/${MONO_VERSION}/wine-mono-${MONO_VERSION#wine-mono-}-x86.msi"
        rm -f "$WINEPREFIX/mono.msi"
        wget -q -O "$WINEPREFIX/mono.msi" "$MONO_URL"
        if [ -f "$WINEPREFIX/mono.msi" ]; then
            wine msiexec /i "$WINEPREFIX/mono.msi" /qn /quiet /norestart /log "$WINEPREFIX/mono_install.log" && \
                printf "${GREEN}Wine Mono was installed successfully!${NC}\n" || \
                printf "${RED}Wine Mono installation failed!${NC}\n"
        else
            printf "${RED}Failed to download Wine Mono MSI.${NC}\n"
        fi
    fi
    WINETRICKS_RUN=$(echo $WINETRICKS_RUN | sed 's/\bmono\b//g')
fi

# Install vcrun2022 64bit if requested (extract DLLs from installer)
if [[ "$WINETRICKS_RUN" =~ vcrun2022 ]]; then
    printf "${BLUE}---------------------------------------------------------------------${NC}\n"
    printf "${YELLOW}Downloading vcrun2022 (Visual C++ Redistributable 2022, 64bit)${NC}\n"
    printf "${BLUE}---------------------------------------------------------------------${NC}\n"
    VCRUN_URL="https://aka.ms/vs/17/release/vc_redist.x64.exe"
    VCRUN_FILE="$WINEPREFIX/vc_redist.x64.exe"
    DLL_DEST="$WINEPREFIX/drive_c/windows/system32"

    rm -f "$VCRUN_FILE"
    wget -q -O "$VCRUN_FILE" "$VCRUN_URL"

    if [ -f "$VCRUN_FILE" ]; then
        printf "${YELLOW}Extracting DLLs from installer...${NC}\n"
        mkdir -p "$DLL_DEST"
        cabextract -d "$DLL_DEST" "$VCRUN_FILE"
        # Check for main DLLs
        DLLS=("msvcp140.dll" "vcruntime140.dll")
        for dll in "${DLLS[@]}"; do
            if [ -f "$DLL_DEST/$dll" ]; then
                printf "${GREEN}$dll successfully extracted to system32.${NC}\n"
            else
                printf "${RED}$dll not found after extraction.${NC}\n"
            fi
        done
    else
        printf "${RED}Failed to download vcrun2022 x64.${NC}\n"
    fi
    WINETRICKS_RUN=$(echo $WINETRICKS_RUN | sed 's/\bvcrun2022\b//g')
fi

# Install additional Winetricks packages
for trick in $WINETRICKS_RUN; do
    printf "${BLUE}---------------------------------------------------------------------${NC}\n"
    printf "${YELLOW}Installing: ${GREEN}%s${NC}\n" "$trick"
    printf "${BLUE}---------------------------------------------------------------------${NC}\n"
    winetricks "$trick"
done

# SteamCMD/DepotDownloader update logic
if [ -d steamcmd ]; then
    if [ -z "$STEAM_USER" ]; then
        printf "${BLUE}---------------------------------------------------------------------${NC}\n"
        printf "${YELLOW}Steam user is not set. Using anonymous user.${NC}\n"
        printf "${BLUE}---------------------------------------------------------------------${NC}\n"
        STEAM_USER="anonymous"
        STEAM_PASS=""
        STEAM_AUTH=""
    else
        printf "${BLUE}---------------------------------------------------------------------${NC}\n"
        printf "${YELLOW}Steam user set to: %s${NC}\n" "$STEAM_USER"
        printf "${BLUE}---------------------------------------------------------------------${NC}\n"
    fi

    if [ -z "$AUTO_UPDATE" ] || [ "$AUTO_UPDATE" = "1" ]; then
        if [ -f ./DepotDownloader ]; then
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
            ./steamcmd/steamcmd.sh +force_install_dir /home/container \
                +login "$STEAM_USER" "$STEAM_PASS" "$STEAM_AUTH" \
                $( [ "$WINDOWS_INSTALL" = "1" ] && echo "+@sSteamCmdForcePlatformType windows" ) \
                $( [ "$STEAM_SDK" = "1" ] && echo "+app_update 1007" ) \
                +app_update "$STEAM_APPID" \
                $( [ -n "$STEAM_BETAID" ] && echo "-beta $STEAM_BETAID" ) \
                $( [ -n "$STEAM_BETAPASS" ] && echo "-betapassword $STEAM_BETAPASS" ) \
                $INSTALL_FLAGS \
                $( [ "$VALIDATE" = "1" ] && echo "validate" ) +quit
        fi
    else
        printf "${BLUE}---------------------------------------------------------------${NC}\n"
        printf "${YELLOW}Auto-update disabled. Starting server without updating.${NC}\n"
        printf "${BLUE}---------------------------------------------------------------${NC}\n"
    fi
fi

# Prepare and execute startup command
MODIFIED_STARTUP=$(echo "${STARTUP}" | sed -e 's/{{/${/g' -e 's/}}/}/g')
printf ":/home/container$ %s\n" "$MODIFIED_STARTUP"
eval "$MODIFIED_STARTUP"
