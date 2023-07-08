FROM    debian:bookworm-slim

LABEL org.opencontainers.image.authors="info@goover.de"

## install required packages
RUN     dpkg --add-architecture i386
RUN     apt update
RUN     apt -y upgrade
RUN     apt install -y \
            gnupg2 \
            software-properties-common \
            libntlm0 \
            winbind \
            xvfb \
            xauth \
            python3 \
            libncurses5:i386 \
            libncurses6:i386 \
            dbus \
            wget \
            curl

# Install wine and with recommends
RUN     mkdir -pm755 /etc/apt/keyrings
RUN     wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key
RUN     wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/debian/dists/bookworm/winehq-bookworm.sources
RUN     apt update
RUN     apt install --install-recommends winehq-staging cabextract -y

# Set up Winetricks
RUN	    wget -q -O /usr/sbin/winetricks https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks
RUN     chmod +x /usr/sbin/winetricks

#Static wine variables
ENV     HOME=/home/container
ENV     WINEPREFIX=/home/container/.wine
ENV     WINE_ARCH=win64
ENV     WINE_PREFIX_GAME_DIR=/home/container/Build
ENV     WINE_PREFIX_GAME_CONFIG=/home/container/Build/config
ENV     WINE_PREFIX_GAME_EXE=/home/container/Build/IR.exe
ENV     WINEDLLOVERRIDES="mscoree,mshtml="
ENV     WINDEBUG=-all
ENV     DISPLAY=:0
ENV     DISPLAY_WIDTH=1024
ENV     DISPLAY_HEIGHT=768
ENV     DISPLAY_DEPTH=16
ENV     AUTO_UPDATE=1
ENV     XVFB=1

USER    container
WORKDIR	/home/container

COPY    ./entrypoint.sh /entrypoint.sh
CMD	    ["/bin/bash", "/entrypoint.sh"]
