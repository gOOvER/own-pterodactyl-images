#!/bin/bash
#System variables
clear
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Switch to the container's working directory
cd /home/container || exit 1

# Wait for the container to fully initialize
sleep 1

# Default the TZ environment variable to UTC.
TZ=${TZ:-UTC}
export TZ

# Set environment variable that holds the Internal Docker IP
INTERNAL_IP=$(ip route get 1 | awk '{print $(NF-2);exit}')
export INTERNAL_IP

# system informations
echo -e "${BLUE}---------------------------------------------------------------------${NC}"
echo -e "${RED}ChampionsBot Image by gOOvER - https://discord.goover.dev${NC}"
echo -e "${BLUE}---------------------------------------------------------------------${NC}"
echo -e "${YELLOW}Linux Distribution: ${RED} $(. /etc/os-release ; echo $PRETTY_NAME)${NC}"
echo -e "${YELLOW}Current timezone: ${RED} $(cat /etc/timezone)${NC}"
echo -e "${BLUE}---------------------------------------------------------------------${NC}"
echo -e "${YELLOW}Java Version: ${RED} $(java -version)${NC}"
echo -e "${YELLOW}NodeJS Version: ${RED} $(node -v) ${NC}"
echo -e "${YELLOW}npm Version: ${RED} $(npm -v) ${NC}"
#echo -e "${YELLOW}yarn Version: ${RED} $(yarn --version) ${NC}"
echo -e "${YELLOW}MongoDB Version: ${RED}$(mongod --version)${NC}"
echo -e "${BLUE}---------------------------------------------------------------------${NC}"

# Replace Startup Variables
MODIFIED_STARTUP=$(echo -e $(echo -e ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g'))
echo -e "${YELLOW}:/home/container${NC} ${MODIFIED_STARTUP}"

# start mongo
echo -e "${BLUE}---------------------------------------------------------------------${NC}"
echo -e "${YELLOW}starting MongoDB...${NC}"
echo -e "${BLUE}---------------------------------------------------------------------${NC}"
mongod --fork --dbpath /home/container/mongodb/ --port 27017 --logpath /home/container/mongod.log --logRotate reopen --logappend && until nc -z -v -w5 127.0.0.1 27017; do echo 'Waiting for mongodb connection...'; sleep 5; done

# Run the Server
echo -e "${BLUE}---------------------------------------------------------------------${NC}"
echo -e "${YELLOW}starting ChampionBot${NC}"
echo -e "${BLUE}---------------------------------------------------------------------${NC}"
eval ${MODIFIED_STARTUP}

# stop mongo
mongod --shutdown
