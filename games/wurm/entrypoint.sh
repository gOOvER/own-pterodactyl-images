#!/bin/bash

clear
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'


# Wait for the container to fully initialize
sleep 1

# Default the TZ environment variable to UTC.
TZ=${TZ:-UTC}
export TZ

# Default the IMAGE_PROMPT environment variable to something nice
IMAGE_PROMPT=${IMAGE_PROMPT:-$'\033[1m\033[33mcontainer@pterodactyl~ \033[0m'}
export IMAGE_PROMPT

# Information output
echo -e "${BLUE}-------------------------------------------------${NC}"
echo -e "${YELLOW}Running on Debian $(cat /etc/debian_version)${NC}"
echo -e "${YELLOW}Current timezone: $(cat /etc/timezone)${NC}"
echo -e "${YELLOW}Java Version:${NC} ${RED} $(java -version)${NC}"
echo -e "${BLUE}-------------------------------------------------${NC}"

# Set environment variable that holds the Internal Docker IP
INTERNAL_IP=$(ip route get 1 | awk '{print $(NF-2);exit}')
export INTERNAL_IP

# Switch to the container's working directory
cd /home/container || exit 1

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

if [[ $XVFB == 1 ]]; then
        Xvfb :0 -screen 0 ${DISPLAY_WIDTH}x${DISPLAY_HEIGHT}x${DISPLAY_DEPTH} &
fi

# Replace Startup Variables
MODIFIED_STARTUP=$(echo ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')
echo ":/home/container$ ${MODIFIED_STARTUP}"

# Run the Server
eval ${MODIFIED_STARTUP}