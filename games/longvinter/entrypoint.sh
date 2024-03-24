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
echo -e "${RED}LongVinter Image by gOOvER${NC}"
echo -e "${BLUE}---------------------------------------------------------------------${NC}"
echo -e "${YELLOW}Running on Debian: ${RED} $(cat /etc/debian_version)${NC}"
echo -e "${YELLOW}Current timezone: ${RED} $(cat /etc/timezone)${NC}"
echo -e "${YELLOW}DotNet Version: ${RED} $(dotnet --version) ${NC}"
echo -e "${BLUE}---------------------------------------------------------------------${NC}"

# Set environment for Steam Proton
if [ -f "/usr/local/bin/proton" ]; then
    if [ ! -z ${SRCDS_APPID} ]; then
	    mkdir -p /home/container/.steam/steam/steamapps/compatdata/${SRCDS_APPID}
        export STEAM_COMPAT_CLIENT_INSTALL_PATH="/home/container/.steam/steam"
        export STEAM_COMPAT_DATA_PATH="/home/container/.steam/steam/steamapps/compatdata/${SRCDS_APPID}"
        #protontricks
        #export STEAM_DIR="/home/container/.steam/steam"
        export WINETRICKS="/usr/sbin/winetricks"
        #export STEAM_RUNTIME=1

    else
        echo -e "${BLUE}----------------------------------------------------------------------------------${NC}"
        echo -e "${RED}WARNING!!! Proton needs variable SRCDS_APPID, else it will not work. Please add it${NC}"
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
    if [ ! -z ${SRCDS_APPID} ]; then
	    if [ "${STEAM_USER}" == "anonymous" ]; then
            ./steamcmd/steamcmd.sh +force_install_dir /home/container +login ${STEAM_USER} ${STEAM_PASS} ${STEAM_AUTH} $( [[ "${WINDOWS_INSTALL}" == "1" ]] && printf %s '+@sSteamCmdForcePlatformType windows' ) +app_update ${SRCDS_APPID} $( [[ -z ${SRCDS_BETAID} ]] || printf %s "-beta ${SRCDS_BETAID}" ) $( [[ -z ${SRCDS_BETAPASS} ]] || printf %s "-betapassword ${SRCDS_BETAPASS}" ) $( [[ -z ${HLDS_GAME} ]] || printf %s "+app_set_config 90 mod ${HLDS_GAME}" ) $( [[ -z ${VALIDATE} ]] || printf %s "validate" ) +quit
	    else
            numactl --physcpubind=+0 ./steamcmd/steamcmd.sh +force_install_dir /home/container +login ${STEAM_USER} ${STEAM_PASS} ${STEAM_AUTH} $( [[ "${WINDOWS_INSTALL}" == "1" ]] && printf %s '+@sSteamCmdForcePlatformType windows' ) +app_update ${SRCDS_APPID} $( [[ -z ${SRCDS_BETAID} ]] || printf %s "-beta ${SRCDS_BETAID}" ) $( [[ -z ${SRCDS_BETAPASS} ]] || printf %s "-betapassword ${SRCDS_BETAPASS}" ) $( [[ -z ${HLDS_GAME} ]] || printf %s "+app_set_config 90 mod ${HLDS_GAME}" ) $( [[ -z ${VALIDATE} ]] || printf %s "validate" ) +quit
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

## Pull Server from Github
if [ -z ${AUTO_UPDATE} ] || [ "${AUTO_UPDATE}" == "1" ]; then
    cd /home/container/longvinter-linux-server
    echo -e "${BLUE}---------------------------------------------------------------------${NC}"
    echo -e "${YELLOW}checkig for Server update. please wait...${NC}"
    echo -e "${BLUE}---------------------------------------------------------------------${NC}"
    git restore .
    sleep 1
    git stash
    sleep 1
    git pull "https://github.com/Uuvana-Studios/longvinter-linux-server.git" main
    sleep 1
    cd /home/container/
    chmod -R ugo+rwx longvinter-linux-server/
else
    echo -e "${BLUE}---------------------------------------------------------------${NC}"
    echo -e "${YELLOW}Not updating game server as auto update was set to 0. Starting Server${NC}"
    echo -e "${BLUE}---------------------------------------------------------------${NC}"
fi

## updating mods
if [ -z ${MODS_UPDATE} ] || [ "${MODS_UPDATE}" == "1" ]; then
    echo -e "${BLUE}---------------------------------------------------------------------${NC}"
    echo -e "${YELLOW}updating mods...${NC}"
    echo -e "${BLUE}---------------------------------------------------------------------${NC}"

STEAMSERVERID=1635450

GAMEMODDIR=./mods
GAMEMODLIST=${GAMEMODDIR}/modlist.txt

cd /home/container

if [ ! -f ./modlist.txt ]; then
    echo -e "${BLUE}---------------------------------------------------------------------${NC}"
    echo -e "${YELLOW}found no modlist.txt. creating one...${NC}"
    echo -e "${BLUE}---------------------------------------------------------------------${NC}"
    touch ./modlist.txt
    echo -e "${GREEN}[DONE]${NC}"
fi

# Clear server modlist so we don't end up with duplicates
echo "" > ${GAMEMODLIST}
MODS=$(awk '{print $1}' ./modlist.txt)

MODCMD="./steamcmd/steamcmd.sh +login anonymous"
for MODID in ${MODS}
do
    echo "Adding $MODID to update list..."
    MODCMD="${MODCMD} +workshop_download_item ${STEAMSERVERID} ${MODID}"
done
MODCMD="${MODCMD} +quit"
${MODCMD}

echo -e "${BLUE}---------------------------------------------------------------------${NC}"
echo -e "${YELLOW}linking mods...${NC}"
echo -e "${BLUE}---------------------------------------------------------------------${NC}"
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

# Replace Startup Variables
MODIFIED_STARTUP=$(echo -e ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')
echo -e ":/home/container$ ${MODIFIED_STARTUP}"

# Run the Server
eval ${MODIFIED_STARTUP}
