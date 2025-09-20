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
echo -e "${RED}SteamCMD Image by gOOvER - https://discord.goover.dev${NC}"
echo -e "${BLUE}---------------------------------------------------------------------${NC}"
echo -e "${YELLOW}Linux Distribution: ${RED} $(. /etc/os-release ; echo $PRETTY_NAME)${NC}"
echo -e "${YELLOW}Current timezone: ${RED} $(cat /etc/timezone)${NC}"
echo -e "${YELLOW}Python Version: ${RED} $(python3 --version) ${NC}"
echo -e "${BLUE}---------------------------------------------------------------------${NC}"

# Switch to the container's working directory
cd /home/container || exit 1

# writing dotnet infos to file
#dotnetinfo=$(dotnet --info)
#echo $dotnetinfo >| dotnet_info.txt

echo -e "${BLUE}---------------------------------------------------------------------${NC}"
echo -e "${GREEN}Starting Server.... Please wait...${NC}"
echo -e "${BLUE}---------------------------------------------------------------------${NC}"

## just in case someone removed the defaults.
if [ "${STEAM_USER:-}" == "" ]; then
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
    ./steamcmd/steamcmd.sh "${sc_args[@]}" || printf "${RED:-}SteamCMD faile${NC:-}C}\n"
fi

# Replace Startup Variables
MODIFIED_STARTUP=$(echo -e ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')
echo -e ":/home/container$ ${MODIFIED_STARTUP}"

# Run the Server
eval ${MODIFIED_STARTUP}

