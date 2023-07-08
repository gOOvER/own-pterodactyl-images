# ---------------------------------------------
# Conan Exile Wine image with Mod support
# ---------------------------------------------
FROM    debian:bookworm-slim

LABEL       author="Torsten Widmann" maintainer="info@goover.de"
LABEL       org.opencontainers.image.source="https://github.com/gOOvER/own-pterodactyl-images"

# Sets the default stop signal as wings can (currently) only send a kill or generic stop
STOPSIGNAL SIGINT

## install required packages
RUN     dpkg --add-architecture i386
RUN     apt update
RUN     apt -y upgrade
RUN     apt install -y --no-install-recommends \
            wget \
            iproute2 \
            gnupg2 \
            software-properties-common \
            libntlm0 \
            winbind \
            xvfb \
            xauth \
            python3 \
            libncurses5-dev:i386 \
            libncurses6 \
            dbus \
            libgdiplus \
            lib32gcc-s1 \
            numactl \
            alsa-tools \
            libpulse-dev \
            libasound2 \
            libao-common \
            gnutls-bin \
            tini

# Install wine and with recommends
RUN     mkdir -pm755 /etc/apt/keyrings
RUN     wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key
RUN     wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/debian/dists/bookworm/winehq-bookworm.sources
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
ENTRYPOINT	["/usr/bin/tini", "-g", "--"]
CMD 		["/entrypoint.sh"]

