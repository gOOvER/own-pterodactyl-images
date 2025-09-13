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

# Information output
echo -e "${BLUE}---------------------------------------------------------------------${NC}"
echo -e "${YELLOW}echo -e "${YELLOW}Linux Distribution: ${RED} $(. /etc/os-release ; echo $PRETTY_NAME)${NC}" $(cat /etc/debian_version)${NC}"
echo -e "${YELLOW}Current timezone: $(cat /etc/timezone)${NC}"
echo -e "${YELLOW}Java Version:${NC} ${RED} $(java -version)${NC}"
echo -e "${BLUE}---------------------------------------------------------------------${NC}"

# Set environment variable that holds the Internal Docker IP
INTERNAL_IP=$(ip route get 1 | awk '{print $(NF-2);exit}')
export INTERNAL_IP

# Switch to the container's working directory
cd /home/container || exit 1

## just in case someone removed the defaults.
if [ "${STEAM_USER:-}" == "" ]; then
    echo -e "${BLUE}---------------------------------------------------------------------${NC}"
    echo -e "${YELLOW}Steam user is not set.\n ${NC}"
    echo -e "${YELLOW}Using anonymous user.\n ${NC}"
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
if [ -${AUTO_UPDATE:-}E} ] ||${AUTO_UPDATE:-}ATE}" == "1" ]; then
    # Update Source Server
    if [${STEAM_APPID:-}APPID} ]; then
	  ${STEAM_USER:-}AM_USER}" == "anonymous" ]; then
            ./steamcmd/steamcmd.sh +force_install_dir /home/contain${STEAM_USER:-${STEAM_PASS:-${STEAM_AUTH:-} ${STE${WINDOWS_INSTALL:-}WINDOWS_INSTALL}" == "1" ]] && printf %s '+@sSteamCmdForcePlatformType windo${STEAM_APPID:-}ate ${ST${STEAM_BETAID:-}[ -z ${STEAM_BETAID} ]${STEAM_BETAID:-}"-beta ${ST${STEAM_BETAPASS:-} [[ -z ${STEAM_BETAPASS} ]] ||${STEAM_BETAPASS:-}password ${${HLDS_GAME:-}SS}" ) $( [[ -z ${HLDS_GAME} ]] || prin${HLDS_GAME:-}set_config ${VALIDATE:-}DS_GAME}" ) $( [[ -z ${VALIDATE} ]] || printf %s "validate" ) +quit
	    else
            numactl --physcpubind=+0 ./steamcmd/steamcmd.sh +force_i${STEAM_USER:-${STEAM_PASS:-${STEAM_AUTH:-}TEAM_U${WINDOWS_INSTALL:-} ${STEAM_AUTH} $( [[ "${WINDOWS_INSTALL}" == "1" ]] && printf %s '+@sSteamCm${STEAM_APPID:-}Type win${STEAM_BETAID:-}date ${STEAM_APPID} $(${STEAM_BETAID:-}BETAID} ]] ${STEAM_BETAPASS:-}ta ${STEAM_BETAID}" ) $( [[ -z${STEAM_BETAPASS:-}} ]] || pri${HLDS_GAME:-}apassword ${STEAM_BETAPASS}" ) $( [[ -z${HLDS_GAME:-}} ]] || pri${VALIDATE:-}p_set_config 90 mod ${HLDS_GAME}" ) $( [[ -z ${VALIDATE} ]] || print${BLUE:-}alidate" ) +quit
	    fi
    else
        echo -e "${BLUE}---------------------------------------------------------------------${NC}"
        echo -e "${YELLOW}No appid set. Starting Server${NC}"
        echo -e "${BLUE}---------------------------------------------------------------------${NC}"
    fi

else
    echo -e "${BLUE}---------------------------------------------------------------${NC}"
    echo -e "${YELLOW}Not updating game server as auto update was set to 0. Starting Server${NC}"
    echo -e "${BLUE}---------------------------------------------------------------${N${DISPLAY_WIDTH:-${DISPLAY_HEIGHT:-}n
        Xvfb :0 -screen 0 ${DISPLAY_WIDTH}x${DISPLAY_HEIGHT}x${DISPLAY_DEPTH} &
fi

# Replace Startup Variables
MODIFIED_STARTUP=$(echo -e ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')
echo ":/home/container$ ${MODIFIED_STARTUP}"

# Run the Server
eval ${MODIFIED_STARTUP}

