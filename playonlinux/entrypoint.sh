#!/bin/bash

# Wait for the container to fully initialize
sleep 1

# Default the TZ environment variable to UTC.
TZ=${TZ:-UTC}
export TZ

# Information output
echo "Running on Debian $(cat /etc/debian_version)"
echo "Current timezone: $(cat /etc/timezone)"
wine --version

# Set environment variable that holds the Internal Docker IP
INTERNAL_IP=$(ip route get 1 | awk '{print $(NF-2);exit}')
export INTERNAL_IP

# Switch to the container's working directory
cd /home/container || exit 1

## just in case someone removed the defaults.
if [ "${STEAM_USER}" == "" ]; then
    echo -e "steam user is not set.\n"
    echo -e "Using anonymous user.\n"
    STEAM_USER=anonymous
    STEAM_PASS=""
    STEAM_AUTH=""
else
    echo -e "user set to ${STEAM_USER}"
fi

## if auto_update is not set or to 1 update
if [ -z ${AUTO_UPDATE} ] || [ "${AUTO_UPDATE}" == "1" ]; then 
    # Update Source Server
    if [ ! -z ${STEAM_APPID} ]; then
        ./steamcmd/steamcmd.sh +force_install_dir /home/container +login ${STEAM_USER} ${STEAM_PASS} ${STEAM_AUTH} $( [[ "${WINDOWS_INSTALL}" == "1" ]] && printf %s '+@sSteamCmdForcePlatformType windows' ) +app_update ${STEAM_APPID} $( [[ -z ${STEAM_BETAID} ]] || printf %s "-beta ${STEAM_BETAID}" ) $( [[ -z ${STEAM_BETAPASS} ]] || printf %s "-betapassword ${STEAM_BETAPASS}" ) +app_update 1007 $( [[ -z ${HLDS_GAME} ]] || printf %s "+app_set_config 90 mod ${HLDS_GAME}" ) $( [[ -z ${VALIDATE} ]] || printf %s "validate" ) +quit
    else
        echo -e "No appid set. Starting Server"
    fi

else
    echo -e "Not updating game server as auto update was set to 0. Starting Server"
fi

if [[ $XVFB == 1 ]]; then
        Xvfb :0 -screen 0 ${DISPLAY_WIDTH}x${DISPLAY_HEIGHT}x${DISPLAY_DEPTH} &
fi

# Install necessary to run packages
echo "First launch will throw some errors. Ignore them"

mkdir -p $WINEPREFIX

# Check if wine-gecko required and install it if so
if [[ $WINETRICKS_RUN =~ gecko ]]; then
        echo "Installing Gecko"
        WINETRICKS_RUN=${WINETRICKS_RUN/gecko}

        if [ ! -f "$WINEPREFIX/gecko_x86.msi" ]; then
                wget -q -O $WINEPREFIX/gecko_x86.msi http://dl.winehq.org/wine/wine-gecko/2.47.2/wine_gecko-2.47.3-x86.msi
        fi

        if [ ! -f "$WINEPREFIX/gecko_x86_64.msi" ]; then
                wget -q -O $WINEPREFIX/gecko_x86_64.msi http://dl.winehq.org/wine/wine-gecko/2.47.2/wine_gecko-2.47.3-x86_64.msi
        fi

        wine msiexec /i $WINEPREFIX/gecko_x86.msi /qn /quiet /norestart /log $WINEPREFIX/gecko_x86_install.log
        wine msiexec /i $WINEPREFIX/gecko_x86_64.msi /qn /quiet /norestart /log $WINEPREFIX/gecko_x86_64_install.log
fi

# Check if wine-mono required and install it if so
if [[ $WINETRICKS_RUN =~ mono ]]; then
        echo "Installing mono"
        WINETRICKS_RUN=${WINETRICKS_RUN/mono}

        if [ ! -f "$WINEPREFIX/mono.msi" ]; then
                wget -q -O $WINEPREFIX/mono.msi https://dl.winehq.org/wine/wine-mono/9.3.0/wine-mono-9.3.0-x86.msi
        fi

        wine msiexec /i $WINEPREFIX/mono.msi /qn /quiet /norestart /log $WINEPREFIX/mono_install.log
fi

# List and install other packages
for trick in $WINETRICKS_RUN; do
        echo "Installing $trick"
        winetricks -q $trick
done

# Replace Startup Variables
MODIFIED_STARTUP=$(echo ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')
echo -e ":/home/container$ ${MODIFIED_STARTUP}"

# Run the Server
eval ${MODIFIED_STARTUP}
