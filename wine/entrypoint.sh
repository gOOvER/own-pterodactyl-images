#!/bin/bash

clear
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'
LINUX=$(. /etc/os-release ; echo $PRETTY_NAME)

# Wait a moment for container initialization
sleep 1

# Set default timezone to UTC if not specified
TZ=${TZ:-UTC}
export TZ

# Output basic container and environment info
echo -e "${BLUE}---------------------------------------------------------------------${NC}"
echo -e "${YELLOW}Wine Image from gOOvER${NC}"
echo -e "${RED}THIS IMAGE IS LICENSED UNDER AGPLv3${NC}"
echo -e "${BLUE}---------------------------------------------------------------------${NC}"
echo -e "${YELLOW}Docker Linux Distribution: ${RED} $(echo $LINUX)${NC}"
echo -e "${YELLOW}Current timezone: $(cat /etc/timezone)${NC}"
echo -e "${YELLOW}Wine Version:${NC} ${RED} $(wine --version)${NC}"
echo -e "${BLUE}---------------------------------------------------------------------${NC}"

# Get internal container IP
INTERNAL_IP=$(ip route get 1 | awk '{print $(NF-2);exit}')
export INTERNAL_IP

# Change to working directory
cd /home/container || exit 1

# Only run auto-update logic if /steamcmd directory exists
if [ -d /home/container/steamcmd ]; then
    # Check if STEAM_USER is set
    if [ -z "$STEAM_USER" ]; then
        echo -e "${BLUE}---------------------------------------------------------------------${NC}"
        echo -e "${YELLOW}Steam user is not set. Using anonymous user.${NC}"
        echo -e "${BLUE}---------------------------------------------------------------------${NC}"
        STEAM_USER="anonymous"
        STEAM_PASS=""
        STEAM_AUTH=""
    else
        echo -e "${BLUE}---------------------------------------------------------------------${NC}"
        echo -e "${YELLOW}Steam user set to: ${STEAM_USER}${NC}"
        echo -e "${BLUE}---------------------------------------------------------------------${NC}"
    fi

    # Check if AUTO_UPDATE is enabled or not set
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
        echo -e "${BLUE}---------------------------------------------------------------${NC}"
        echo -e "${YELLOW}Auto-update disabled. Starting server without updating.${NC}"
        echo -e "${BLUE}---------------------------------------------------------------${NC}"
    fi
fi

# Start virtual framebuffer if enabled
if [[ $XVFB == 1 ]]; then
    Xvfb :0 -screen 0 ${DISPLAY_WIDTH}x${DISPLAY_HEIGHT}x${DISPLAY_DEPTH} &
fi

# Create WINEPREFIX directory if it doesn't exist
echo -e "${BLUE}---------------------------------------------------------------------${NC}"
echo -e "${RED}First launch will throw some errors. Ignore them${NC}"
echo -e "${BLUE}---------------------------------------------------------------------${NC}"
mkdir -p $WINEPREFIX

# Install Wine Gecko if requested
if [[ $WINETRICKS_RUN =~ gecko ]]; then
    echo -e "${BLUE}---------------------------------------------------------------------${NC}"
    echo -e "${YELLOW}Installing Wine Gecko${NC}"
    echo -e "${BLUE}---------------------------------------------------------------------${NC}"
    WINETRICKS_RUN=${WINETRICKS_RUN/gecko}
    [ ! -f "$WINEPREFIX/gecko_x86.msi" ] && wget -q -O $WINEPREFIX/gecko_x86.msi http://dl.winehq.org/wine/wine-gecko/2.47.4/wine_gecko-2.47.4-x86.msi
    [ ! -f "$WINEPREFIX/gecko_x86_64.msi" ] && wget -q -O $WINEPREFIX/gecko_x86_64.msi http://dl.winehq.org/wine/wine-gecko/2.47.4/wine_gecko-2.47.4-x86_64.msi
    wine msiexec /i $WINEPREFIX/gecko_x86.msi /qn /quiet /norestart /log $WINEPREFIX/gecko_x86_install.log
    wine msiexec /i $WINEPREFIX/gecko_x86_64.msi /qn /quiet /norestart /log $WINEPREFIX/gecko_x86_64_install.log
fi

# Install Wine Mono if requested
if [[ $WINETRICKS_RUN =~ mono ]]; then
    echo -e "${BLUE}---------------------------------------------------------------------${NC}"
    echo -e "${YELLOW}Installing Wine Mono (32-bit only)${NC}"
    echo -e "${BLUE}---------------------------------------------------------------------${NC}"
    WINETRICKS_RUN=${WINETRICKS_RUN/mono/}

    # Define the download URL
    MONO_URL="https://github.com/wine-mono/wine-mono/releases/latest/download/wine-mono-x86.msi"

    # Remove existing MSI if it exists, then download the latest
    [ -f "$WINEPREFIX/mono.msi" ] && rm -f "$WINEPREFIX/mono.msi"
    wget -q -O "$WINEPREFIX/mono.msi" "$MONO_URL"

    # Install 32-bit Wine Mono
    if [ -f "$WINEPREFIX/mono.msi" ]; then
        wine msiexec /i "$WINEPREFIX/mono.msi" /qn /quiet /norestart /log "$WINEPREFIX/mono_install.log"
    else
        echo -e "${RED}Failed to download Wine Mono MSI.${NC}"
    fi
fi

# Run additional winetricks packages
for trick in $WINETRICKS_RUN; do
    echo -e "${BLUE}---------------------------------------------------------------------${NC}"
    echo -e "${YELLOW}Installing: ${NC} ${GREEN} $trick ${NC}"
    echo -e "${BLUE}---------------------------------------------------------------------${NC}"
    winetricks -q $trick
done

# Replace {{VARIABLE}} in startup with actual environment values and run it
MODIFIED_STARTUP=$(echo ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')
echo ":/home/container$ ${MODIFIED_STARTUP}"
eval ${MODIFIED_STARTUP}
