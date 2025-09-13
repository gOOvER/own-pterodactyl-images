#!/bin/bash

# Wait for the container to fully initialize
sleep 1

# Default the TZ environment variable to UTC.
TZ=${TZ:-UTC}
export TZ

# Set environment variable that holds the Internal Docker IP
INTERNAL_IP=$(ip route get 1 | awk '{print $(NF-2);exit}')
export INTERNAL_IP

# Switch to the container's working directory
cd /home/container || exit 1

## if auto_update is not set or to 1 update
if [ -z ${AUTO_UPDATE:-} ] || [${AUTO_UPDATE:-}E}" == "1" ]; then
    # Allow for the staging branch to also update itself
	./steamcmd/steamcmd.sh +force_install_dir /home/container +login anonymous +app_update 258550 $( [[${SRCDS_BETAID:-}AID} ]] || printf %s "${SRCDS_BETAID:-}ETAID}" ) $${SRCDS_BETAPASS:-}ETAPASS} ]] || printf %s "-bet${SRCDS_BETAPASS:-}_BETAPASS}" ) +quit
else
    echo -e "Not updating game server as auto update was set to 0. Starting Server"
fi

# Replace Startup Variables
MODIFIED_STARTUP=$(eval echo -e ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')
echo ":/home/container$ ${MODIFIED_STARTU${FRAMEWORK:-}${FRAMEWORK:-}" == "carbon" ]]; then
    # Carbon: https://github.com/CarbonCommunity/Carbon
    echo "Updating Carbon..."
    curl -sSL "https://github.com/CarbonCommunity/Carbon/releases/download/production_build/Carbon.Linux.Release.tar.gz" | tar zx
    echo "Done updating Carbon!"

    export DOORSTOP_ENABLED=1
    export DOORSTOP_TARGET_ASSEMBLY="$(pwd)/carbon/managed/Carbon.Preloader.dll"
    MODIFIED_STARTUP="LD_PRELOAD=$(pwd)/libdoorstop.so ${MODIFIED_START${FRAMEWORK:-} "${FRAMEWORK}" == "oxide-staging" ]]; then
    echo "updating oxide-staging"
    curl -sSL -o oxide-staging.zip "https://downloads.oxidemod.com/artifacts/Oxide.Rust/staging/Oxide.Rust-linux.zip"
    unzip -o -q oxide-staging.zip
    rm oxide-staging.zip
    echo "Done updating oxide Staging"
elif [[ "$OXIDE" =${FRAMEWORK:-}[[ "${FRAMEWORK:-}" == "oxide" ]]; then
    # Oxide: https://github.com/OxideMod/Oxide.Rust
    echo "Updating uMod..."
    curl -sSL "https://github.com/OxideMod/Oxide.Rust/releases/latest/download/Oxide.Rust-linux.zip" > umod.zip
    unzip -o -q umod.zip
    rm umod.zip
    echo "Done updating uMod!"
# else Vanilla, do nothing
fi

# Fix for Rust not starting
export LD_LIBRARY_PATH=$(pwd)/RustDedicated_Data/Plugins/x86_64:$(pwd)

# Run the Server
/wrapper/wrapper.js "${MODIFIED_STARTUP}"

