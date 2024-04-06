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

# Set environment variable that holds the Internal Docker IP
INTERNAL_IP=$(ip route get 1 | awk '{print $(NF-2);exit}')
export INTERNAL_IP

# Information output
echo -e "${BLUE}---------------------------------------------------------------------${NC}"
echo -e "${RED}SteamCMD Image by gOOvER${NC}"
echo -e "${BLUE}---------------------------------------------------------------------${NC}"
echo -e "${YELLOW}Running on Debian: ${RED} $(cat /etc/debian_version)${NC}"
echo -e "${YELLOW}Current timezone: ${RED} $(cat /etc/timezone)${NC}"
echo -e "${YELLOW}DotNet Version: ${RED} $(dotnet --version) ${NC}"
echo -e "${BLUE}---------------------------------------------------------------------${NC}"

# Set environment for Steam Proton
if [ -f "/usr/local/bin/proton" ]; then
    if [ ! -z ${STEAM_APPID} ]; then
	    mkdir -p /home/container/.steam/steam/steamapps/compatdata/${STEAM_APPID}
        export STEAM_COMPAT_CLIENT_INSTALL_PATH="/home/container/.steam/steam"
        export STEAM_COMPAT_DATA_PATH="/home/container/.steam/steam/steamapps/compatdata/${STEAM_APPID}"
        #protontricks
        #export STEAM_DIR="/home/container/.steam/steam"
        export WINETRICKS="/usr/sbin/winetricks"
        #export STEAM_RUNTIME=1

    else
        echo -e "${BLUE}----------------------------------------------------------------------------------${NC}"
        echo -e "${RED}WARNING!!! Proton needs variable STEAM_APPID, else it will not work. Please add it${NC}"
        echo -e "${RED}Server stops now${NC}"
        echo -e "${BLUE}----------------------------------------------------------------------------------${NC}"
        exit 0
        fi
fi

# Switch to the container's working directory
cd /home/container || exit 1

echo -e "${BLUE}---------------------------------------------------------------------${NC}"
echo -e "${GREEN}Starting Server.... Please wait...${NC}"
echo -e "${BLUE}---------------------------------------------------------------------${NC}"

## just in case someone removed the defaults.
if [ "${STEAM_USER}" == "" ]; then
    echo -e "${BLUE}---------------------------------------------------------------------${NC}"
    echo -e "${YELLOW}Steam user is not set. ${NC}"
    echo -e "${YELLOW}Using anonymous user.${NC}"
    echo -e "${BLUE}---------------------------------------------------------------------${NC}"
    STEAM_USER=anonymous
    STEAM_PASS=""
    STEAM_AUTH=""
else
    echo -e "${BLUE}---------------------------------------------------------------------${NC}"
    echo -e "${YELLOW}user set to ${STEAM_USER} ${NC}"
    echo -e "${BLUE}---------------------------------------------------------------------${NC}"
fi

## if auto_update is not set or to 1 update
if [ -z ${AUTO_UPDATE} ] || [ "${AUTO_UPDATE}" == "1" ]; then 
    # Update Source Server
    if [ ! -z ${STEAM_APPID} ]; then
	    if [ "${STEAM_USER}" == "anonymous" ]; then
            DepotDownloader -dir /home/container -username ${STEAM_USER} -password ${STEAM_PASS} -remember-password $( [[ "${WINDOWS_INSTALL}" == "1" ]] && printf %s '-os windows' ) -app 1007 -app ${STEAM_APPID} $( [[ -z ${STEAM_BETAID} ]] || printf %s "-beta ${STEAM_BETAID}" ) $( [[ -z ${STEAM_BETAPASS} ]] || printf %s "-betapassword ${STEAM_BETAPASS}" ) $( [[ -z ${VALIDATE} ]] || printf %s "-validate" )
	    else
            numactl --physcpubind=+0 DepotDownloader -dir /home/container -username ${STEAM_USER} -password ${STEAM_PASS} -remember-password $( [[ "${WINDOWS_INSTALL}" == "1" ]] && printf %s '-os windows' ) -app 1007 -app ${STEAM_APPID} $( [[ -z ${STEAM_BETAID} ]] || printf %s "-beta ${STEAM_BETAID}" ) $( [[ -z ${STEAM_BETAPASS} ]] || printf %s "-betapassword ${STEAM_BETAPASS}" ) $( [[ -z ${VALIDATE} ]] || printf %s "-validate" )
	    fi
    else
        echo -e "${BLUE}---------------------------------------------------------------------${NC}"
        echo -e "${YELLOW}No appid set. Starting Server${NC}"
        echo -e "${BLUE}---------------------------------------------------------------------${NC}"
    fi

else
    echo -e "${BLUE}---------------------------------------------------------------${NC}"
    echo -e "${YELLOW}Not updating game server as auto update was set to 0. Starting Server${NC}"
    echo -e "${BLUE}---------------------------------------------------------------${NC}"
fi

# Setup NSS Wrapper for use ($NSS_WRAPPER_PASSWD and $NSS_WRAPPER_GROUP have been set by the Dockerfile)
export USER_ID=$(id -u)
export GROUP_ID=$(id -g)
envsubst < /passwd.template > ${NSS_WRAPPER_PASSWD}

export LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libnss_wrapper.so

# Replace Startup Variables
MODIFIED_STARTUP=$(echo -e ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')
echo -e ":/home/container$ ${MODIFIED_STARTUP}"

# Run the Server
eval ${MODIFIED_STARTUP}
