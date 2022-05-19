FROM    ghcr.io/goover/yolks_os:debian11

LABEL   author="Torsten Widmann" maintainer="info@goover.de"

## install required packages
RUN     dpkg --add-architecture i386
RUN     apt update
RUN     apt install -y --no-install-recommends gnupg2 software-properties-common libntlm0 winbind xvfb xauth python3 libncurses5:i386 libncurses6:i386 dbus

RUN     useradd -g 1000 -m -d /home/container container

# Install winehq-stable and with recommends
RUN     wget -nc https://dl.winehq.org/wine-builds/winehq.key
RUN     apt-key add winehq.key
RUN     apt-add-repository 'deb http://dl.winehq.org/wine-builds/debian/ bullseye main'
RUN     apt update
RUN     apt install --install-recommends winehq-stable cabextract -y

# Set up Winetricks
RUN	    wget -q -O /usr/sbin/winetricks https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks
RUN     chmod +x /usr/sbin/winetricks

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

#Static wine variables

USER    container
WORKDIR	/home/container

COPY    ./entrypoint.sh /entrypoint.sh
CMD	    ["/bin/bash", "/entrypoint.sh"]
