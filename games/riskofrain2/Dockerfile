# ----------------------------------
# Risk of Rain 2 Wine image
# ----------------------------------
FROM    debian:bookworm-slim

LABEL       author="Torsten Widmann" maintainer="info@goover.de"
LABEL       org.opencontainers.image.source="https://github.com/gOOvER/own-pterodactyl-images"
LABEL       org.opencontainers.image.licenses=MIT


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
           wget \
           curl \
           libncurses5:i386 \
           libncurses6:i386 \
           libgdiplus \
           lib32gcc-s1

# Install winehq-stable and with recommends
RUN     mkdir -pm755 /etc/apt/keyrings
RUN     wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key
RUN     wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/debian/dists/bookworm/winehq-bookworm.sources
RUN     apt update
RUN     apt install -y --install-recommends winehq-stable cabextract

# Set up Winetricks
RUN	    wget -q -O /usr/sbin/winetricks https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks
RUN     chmod +x /usr/sbin/winetricks

ENV     WINEPREFIX=/home/container/.wine
ENV     WINEDLLOVERRIDES="mscoree,mshtml="
ENV     WINDEBUG=-all
ENV     DISPLAY=:0
ENV     DISPLAY_WIDTH=1024
ENV     DISPLAY_HEIGHT=768
ENV     DISPLAY_DEPTH=16
ENV     AUTO_UPDATE=1
ENV     XVFB=1

## Setup user and working directory
RUN         useradd -m -d /home/container -s /bin/bash container
USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

COPY    ./entrypoint.sh /entrypoint.sh
CMD	    ["/bin/bash", "/entrypoint.sh"]
