#!/bin/bash
cd /home/container

# Information output
echo "Running on Debian $(cat /etc/debian_version)"
echo "Current timezone: $(cat /etc/timezone)"
wine --version

# Set environment variable that holds the Internal Docker IP
INTERNAL_IP=$(ip route get 1 | awk '{print $(NF-2);exit}')
export INTERNAL_IP

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
        ./steamcmd/steamcmd.sh +force_install_dir /home/container +login ${STEAM_USER} ${STEAM_PASS} ${STEAM_AUTH} $( [[ "${WINDOWS_INSTALL}" == "1" ]] && printf %s '+@sSteamCmdForcePlatformType windows' ) +app_update ${STEAM_APPID} $( [[ ! -z ${STEAM_BETAID} ]] && printf %s "-beta ${STEAM_BETAID}" ) $( [[ ! -z ${STEAM_BETAPASS} ]] && printf %s "-betapassword ${STEAM_BETAPASS}" ) $( [[ ! -z ${HLDS_GAME} ]] && printf %s "+app_set_config 90 mod ${HLDS_GAME}" ) $( [[ ! -z ${VALIDATE} ]] && printf %s "validate" ) +quit
    else
        echo -e "No appid set. Starting Server"
    fi
else
    echo -e "Not updating game server as auto update was set to 0. Starting Server"
fi

if [[ $XVFB == 1 ]]; then
        Xvfb :0 -screen 0 ${DISPLAY_WIDTH}x${DISPLAY_HEIGHT}x${DISPLAY_DEPTH} &
fi

# BepInEx install
if [ -f BEPINEX_FLAG ] || [ "${BEPINEX}" = 1 ] ; then
    echo "Updating BepInEx..."
    curl -sSL "https://thunderstore.io/package/download/bbepis/BepInExPack/${BEP_VERSION}/" > bepinex.zip
    unzip -o -q bepinex.zip
    mv -f /home/container/BepInExPack/* /home/container
    rm -f bepinex.zip
    rm -fR /home/container/BepInExPack
    echo "Done installing BepInEx!"
else
    echo "Removing BepInEx..."
     rm -fR BepInEx
     rm -f doorstop_config.ini
     rm -f winhttp.dll
     echo "Done removing BepInEx"
fi

#cleanup
rm -f icon.png
rm -f README.md
rm -f manifest.json

# Install necessary to run packages
echo "First launch will throw some errors. Ignore them"

mkdir -p $WINEPREFIX

# Check if wine-gecko required and install it if so
if [[ $WINETRICKS_RUN =~ gecko ]]; then
        echo -e "${BLUE}---------------------------------------------------------------------${NC}"
        echo -e "${YELLOW}Installing Wine Gecko${NC}"
        echo -e "${BLUE}---------------------------------------------------------------------${NC}"
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
        echo -e "${BLUE}---------------------------------------------------------------------${NC}"
        echo -e "${YELLOW}Installing Wine Mono${NC}"
        echo -e "${BLUE}---------------------------------------------------------------------${NC}"
        WINETRICKS_RUN=${WINETRICKS_RUN/mono}

        if [ ! -f "$WINEPREFIX/mono.msi" ]; then
                wget -q -O $WINEPREFIX/mono.msi https://dl.winehq.org/wine/wine-mono/8.0.0/wine-mono-8.0.0-x86.msi
        fi

        wine msiexec /i $WINEPREFIX/mono.msi /qn /quiet /norestart /log $WINEPREFIX/mono_install.log
fi

# List and install other packages
for trick in $WINETRICKS_RUN; do
        echo -e "${BLUE}---------------------------------------------------------------------${NC}"
        echo -e "${YELLOW}Installing: ${NC} ${GREEN} $trick ${NC}"
        echo -e "${BLUE}---------------------------------------------------------------------${NC}"
        winetricks -q $trick
done

# Replace Startup Variables
MODIFIED_STARTUP=$(echo ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')
echo ":/home/container$ ${MODIFIED_STARTUP}"

# Run the Server
eval ${MODIFIED_STARTUP}
