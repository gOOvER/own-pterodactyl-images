# ---------------------------------------------
# Conan Exile Wine image with Mod support
# ---------------------------------------------
FROM    ghcr.io/pteroforge/debian:11-bullseye

LABEL org.opencontainers.image.authors="info@goover.de"

## install required packages
RUN     dpkg --add-architecture i386
RUN     apt update
RUN     apt install -y --no-install-recommends wget iproute2 gnupg2 software-properties-common libntlm0 winbind xvfb xauth python3 libncurses5-dev:i386 libncurses6 dbus libgdiplus lib32gcc-s1
RUN     apt install -y alsa-tools libpulse-dev libasound2 libao-common gnutls-bin

# Install winehq-stable and with recommends
RUN     wget -nc https://dl.winehq.org/wine-builds/winehq.key
RUN     mv winehq.key /usr/share/keyrings/winehq-archive.key
RUN     wget -nc https://dl.winehq.org/wine-builds/debian/dists/bullseye/winehq-bullseye.sources
RUN     mv winehq-bullseye.sources /etc/apt/sources.list.d/
RUN     apt update
RUN     apt install --install-recommends winehq-staging cabextract -y

# Set up Winetricks
RUN	    wget -q -O /usr/sbin/winetricks https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks
RUN     chmod +x /usr/sbin/winetricks

ENV     HOME=/home/container
ENV     WINEPREFIX=/home/container/.wine
ENV     WINEDLLOVERRIDES="mscoree,mshtml="
ENV     DISPLAY=:0
ENV     DISPLAY_WIDTH=1024
ENV     DISPLAY_HEIGHT=768
ENV     DISPLAY_DEPTH=16
ENV     AUTO_UPDATE=1
ENV     XVFB=1

USER    container
ENV     USER=container HOME=/home/container
WORKDIR /home/container

COPY    ./entrypoint.sh /entrypoint.sh
CMD	    ["/bin/bash", "/entrypoint.sh"]

