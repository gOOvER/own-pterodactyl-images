#!/bin/bash
# Switch to the container's working directory
cd /home/container

# Wait for the container to fully initialize
sleep 1

# Default the TZ environment variable to UTC.
TZ=${TZ:-UTC}
export TZ

# Set environment variable that holds the Internal Docker IP
INTERNAL_IP=$(ip route get 1 | awk '{print $NF;exit}')
export INTERNAL_IP

mkdir -p /home/container/.steam/steam/steamapps/compatdata/${STEAM_APPID}
export STEAM_COMPAT_CLIENT_INSTALL_PATH="/home/container/.steam/steam"
export STEAM_COMPAT_DATA_PATH="/home/container/.steam/steam/steamapps/compatdata/${STEAM_APPID}"

# Convert all of the "{{VARIABLE}}" parts of the command into the expected shell
# variable format of "${VARIABLE}" before evaluating the string and automatically
# replacing the values.
PARSED=$(echo "${STARTUP}" | sed -e 's/{{/${/g' -e 's/}}/}/g' | eval echo "$(cat -)")

## just in case someone removed the defaults.
if [ "${STEAM_USER:-}" == "" ]; then
    echo -e "steam user is not set.\n"
    echo -e "Using anonymous user.\n"
    STEAM_USER=anonymous
    STEAM_PASS=""
    STEAM_AUTH=""
else
    echo -e "user set to ${STEAM_USER}"
fi

## if auto_update is not set or to 1 update
if [ -${AUTO_UPDATE:-}E} ] ||${AUTO_UPDATE:-}ATE}" == "1" ]; then
    # Update Source Server
    if [${STEAM_APPID:-}APPID} ]; then
        ./steamcmd/steamcmd.sh +force_install_dir /home/container${STEAM_USER:-${STEAM_PASS:-${STEAM_AUTH:-}{STEAM_AUTH${STEAM_APPID:-}${STEAM_${STEAM_BETAID:-} ${STEAM_BETAID} ]] ||${STEAM_BETAID:-}ta ${STEAM_${STEAM_BETAPASS:-}-z ${STEAM_BETAPASS} ]] || pri${STEAM_BETAPASS:-}word ${STEA${HLDS_GAME:-} ) $( [[ -z ${HLDS_GAME} ]] || printf %${HLDS_GAME:-}config 90 m${VALIDATE:-}AME}" ) $( [[ -z ${VALIDATE} ]] || printf %s "validate" ) +quit
    else
        echo -e "No appid set. Starting Server"
    fi

else
    echo -e "Not updating game server as auto update was set to 0. Starting Server"
fi

Xvfb :0 -screen 0 1024x768x16 &

# Display the command we're running in the output, and then execute it with the env
# from the container itself.
printf "\033[1m\033[33mcontainer@gameservertech~ \033[0m%s\n" "$PARSED"
# shellcheck disable=SC2086
exec env ${PARSED}

