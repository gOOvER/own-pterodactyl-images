FROM    debian:bookworm-slim

LABEL       author="Torsten Widmann" maintainer="info@goover.de"
LABEL       org.opencontainers.image.source="https://github.com/gOOvER/own-pterodactyl-images"

## install required packages
ARG             DEBIAN_FRONTEND=noninteractive
RUN             dpkg --add-architecture i386
RUN             apt update
RUN             apt -y upgrade
RUN             apt install -y \
                    apt-transport-https \
                    binutils \
                    ca-certificates \
                    cabextract \
                    curl \
                    dos2unix \
                    g++ \
                    gcc \
                    gdb \
                    git \
                    gnupg2 \
					gnutls-bin \
                    icu-devtools \
                    iproute2 \
                    locales \
                    net-tools \
                    netcat-openbsd \
                    numactl \
                    procps \
                    python3 \
                    rapidjson-dev \
                    software-properties-common \
                    sqlite3 \
                    tar \
                    telnet \
                    tini \
                    tzdata \
                    unzip \
                    wget \
                    winbind \
                    xauth \
                    xvfb \
                    xz-utils \
                    zip \
                    libc++-dev \
                    libc6 \
                    libduktape207 \
                    libevent-dev \
                    libfontconfig \
                    libgcc1 \
                    libicu72 \
                    liblua5.4-0 \
                    liblzo2-2 \
                    libmariadbclient-dev-compat \
                    libncurses6:i386 \
                    libntlm0 \
                    libsdl1.2debian \
                    libsdl2-2.0-0 \
                    libsdl2-2.0-0:i386 \
                    libsqlite3-dev \
                    libstdc++6 \
                    libz-dev \
                    libzip4 \
                    libsystemd0:i386
            
RUN             rm -rf /var/lib/apt/lists/*

# Install wine and with recommends
RUN     mkdir -pm755 /etc/apt/keyrings
RUN     wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key
RUN     wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/debian/dists/bookworm/winehq-bookworm.sources
RUN     apt update
RUN     apt install winehq-staging cabextract -y

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

# Sets the default stop signal as wings can (currently) only send a kill or generic stop
STOPSIGNAL SIGINT

## Setup user and working directory
RUN         useradd -m -d /home/container -s /bin/bash container
USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

## Copy over and execute entrypoint.sh
RUN         dos2unix /entrypoint.sh
COPY        --chown=container:container ./entrypoint.sh /entrypoint.sh
RUN         chmod +x /entrypoint.sh
ENTRYPOINT	["/usr/bin/tini", "-g", "--"]
CMD 		["/entrypoint.sh"]
