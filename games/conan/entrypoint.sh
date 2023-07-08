#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

cd /home/container

# Information output
echo
echo -e "${BLUE}-------------------------------------------------${NC}"
echo -e "${YELLOW}Conan Exile Docker Image with Mod Support${NC}"
echo -e "${YELLOW}Copyright 2023 by gOOvER${NC}"
echo -e "${BLUE}-------------------------------------------------${NC}" 
echo "Running on Debian $(cat /etc/debian_version)"
echo "Current timezone: $(cat /etc/timezone)"
wine --version

# Set environment variable that holds the Internal Docker IP
INTERNAL_IP=$(ip route get 1 | awk '{print $(NF-2);exit}')
export INTERNAL_IP

## just in case someone removed the defaults.
if [ "${STEAM_USER}" == "" ]; then
    echo -e "${BLUE}-------------------------------------------------${NC}"
    echo -e "${YELLOW}Steam user is not set.\n ${NC}"
    echo -e "${YELLOW}Using anonymous user.\n ${NC}"
    echo -e "${BLUE}-------------------------------------------------${NC}"
    STEAM_USER=anonymous
    STEAM_PASS=""
    STEAM_AUTH=""
else
    echo -e "${BLUE}-------------------------------------------------${NC}"
    echo -e "${YELLOW}user set to ${STEAM_USER} ${NC}"
    echo -e "${BLUE}-------------------------------------------------${NC}"
fi

## if auto_update is not set or to 1 update
if [ -z ${AUTO_UPDATE} ] || [ "${AUTO_UPDATE}" == "1" ]; then 
    # Update Source Server
    if [ ! -z ${SRCDS_APPID} ]; then
	    if [ "${STEAM_USER}" == "anonymous" ]; then
            ./steamcmd/steamcmd.sh +force_install_dir /home/container +login ${STEAM_USER} ${STEAM_PASS} ${STEAM_AUTH} $( [[ "${WINDOWS_INSTALL}" == "1" ]] && printf %s '+@sSteamCmdForcePlatformType windows' ) +app_update ${SRCDS_APPID} $( [[ -z ${SRCDS_BETAID} ]] || printf %s "-beta ${SRCDS_BETAID}" ) $( [[ -z ${SRCDS_BETAPASS} ]] || printf %s "-betapassword ${SRCDS_BETAPASS}" ) $( [[ -z ${HLDS_GAME} ]] || printf %s "+app_set_config 90 mod ${HLDS_GAME}" ) $( [[ -z ${VALIDATE} ]] || printf %s "validate" ) +quit
	    else
            numactl --physcpubind=+0 ./steamcmd/steamcmd.sh +force_install_dir /home/container +login ${STEAM_USER} ${STEAM_PASS} ${STEAM_AUTH} $( [[ "${WINDOWS_INSTALL}" == "1" ]] && printf %s '+@sSteamCmdForcePlatformType windows' ) +app_update ${SRCDS_APPID} $( [[ -z ${SRCDS_BETAID} ]] || printf %s "-beta ${SRCDS_BETAID}" ) $( [[ -z ${SRCDS_BETAPASS} ]] || printf %s "-betapassword ${SRCDS_BETAPASS}" ) $( [[ -z ${HLDS_GAME} ]] || printf %s "+app_set_config 90 mod ${HLDS_GAME}" ) $( [[ -z ${VALIDATE} ]] || printf %s "validate" ) +quit
	    fi
    else
        echo -e "${BLUE}-------------------------------------------------${NC}"
        echo -e "${YELLOW}No appid set. Starting Server${NC}"
        echo -e "${BLUE}-------------------------------------------------${NC}"
    fi
else
    echo -e "${BLUE}---------------------------------------------------------------${NC}"
    echo -e "${YELLOW}Not updating game server as auto update was set to 0. Starting Server${NC}"
    echo -e "${BLUE}---------------------------------------------------------------${NC}"
fi

## updating mods
if [ -z ${MODS_UPDATE} ] || [ "${MODS_UPDATE}" == "1" ]; then
    echo -e "${BLUE}-------------------------------------------------${NC}"
    echo -e "${YELLOW}updating mods...${NC}"
    echo -e "${BLUE}-------------------------------------------------${NC}"

STEAMSERVERID=440900

GAMEMODDIR=./ConanSandbox/Mods
GAMEMODLIST=${GAMEMODDIR}/modlist.txt

cd /home/container

if [ ! -f ./modlist.txt ]; then
    echo -e "${BLUE}-------------------------------------------------${NC}"
    echo -e "${YELLOW}found no modlist.txt. creating one...${NC}"
    echo -e "${BLUE}-------------------------------------------------${NC}"
    touch ./modlist.txt
    echo -e "${GREEN}[DONE]${NC}"
fi

# Clear server modlist so we don't end up with duplicates
echo "" > ${GAMEMODLIST}
MODS=$(awk '{print $1}' ./modlist.txt)

MODCMD="./steamcmd/steamcmd.sh +@sSteamCmdForcePlatformType windows +login anonymous"
for MODID in ${MODS}
do
    echo "Adding $MODID to update list..."
    MODCMD="${MODCMD} +workshop_download_item ${STEAMSERVERID} ${MODID}"
done
MODCMD="${MODCMD} +quit"
${MODCMD}

echo -e "${BLUE}-------------------------------------------------${NC}"
echo -e "${YELLOW}linking mods...${NC}"
echo -e "${BLUE}-------------------------------------------------${NC}"
mkdir -p ${GAMEMODDIR}
# make dir to prevent errors
mkdir -p /home/container/Steam/steamapps/workshop

for MODID in ${MODS}
do
    echo -e "${BLUE}Linking ${NC}${RED}$MODID${NC}"
    MODDIR=/home/container/Steam/steamapps/workshop/content/${STEAMSERVERID}/${MODID}/
    find "${MODDIR}" -iname '*.pak' >> ${GAMEMODLIST}
done
fi
echo -e "${GREEN}[DONE]${NC}"


if [[ $XVFB == 1 ]]; then
        Xvfb :0 -screen 0 ${DISPLAY_WIDTH}x${DISPLAY_HEIGHT}x${DISPLAY_DEPTH} &
fi

# Install necessary to run packages
echo -e "${BLUE}---------------------------------------------------${NC}"
echo -e "${YELLOW}First launch will throw some errors. Ignore them${NC}"
echo -e "${BLUE}---------------------------------------------------${NC}"

mkdir -p $WINEPREFIX

# Check if wine-gecko required and install it if so
if [[ $WINETRICKS_RUN =~ gecko ]]; then
        echo -e "${BLUE}-------------------------------------------------${NC}"
        echo -e "${YELLOW}Installing Wine Gecko${NC}"
        echo -e "${BLUE}-------------------------------------------------${NC}"
        WINETRICKS_RUN=${WINETRICKS_RUN/gecko}

        if [ ! -f "$WINEPREFIX/gecko_x86.msi" ]; then
                wget -q -O $WINEPREFIX/gecko_x86.msi http://dl.winehq.org/wine/wine-gecko/2.47.4/wine_gecko-2.47.4-x86.msi
        fi

        if [ ! -f "$WINEPREFIX/gecko_x86_64.msi" ]; then
                wget -q -O $WINEPREFIX/gecko_x86_64.msi http://dl.winehq.org/wine/wine-gecko/2.47.4/wine_gecko-2.47.4-x86_64.msi
        fi

        wine msiexec /i $WINEPREFIX/gecko_x86.msi /qn /quiet /norestart /log $WINEPREFIX/gecko_x86_install.log
        wine msiexec /i $WINEPREFIX/gecko_x86_64.msi /qn /quiet /norestart /log $WINEPREFIX/gecko_x86_64_install.log
fi

# Check if wine-mono required and install it if so
if [[ $WINETRICKS_RUN =~ mono ]]; then
        echo -e "${BLUE}-------------------------------------------------${NC}"
        echo -e "${YELLOW}Installing Wine Mono${NC}"
        echo -e "${BLUE}-------------------------------------------------${NC}"
        WINETRICKS_RUN=${WINETRICKS_RUN/mono}

        if [ ! -f "$WINEPREFIX/mono.msi" ]; then
                wget -q -O $WINEPREFIX/mono.msi https://dl.winehq.org/wine/wine-mono/8.0.0/wine-mono-8.0.0-x86.msi
        fi

        wine msiexec /i $WINEPREFIX/mono.msi /qn /quiet /norestart /log $WINEPREFIX/mono_install.log
fi

# List and install other packages
for trick in $WINETRICKS_RUN; do
        echo -e "${BLUE}-------------------------------------------------${NC}"
        echo -e "${YELLOW}Installing: ${NC} ${GREEN} $trick ${NC}"
        echo -e "${BLUE}-------------------------------------------------${NC}"
        winetricks -q $trick
done

# Replace Startup Variables
MODIFIED_STARTUP=$(echo ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')
echo ":/home/container$ ${MODIFIED_STARTUP}"

# Run the Server
eval ${MODIFIED_STARTUP}
