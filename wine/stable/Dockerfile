FROM            debian:bookworm-slim

LABEL           author="Torsten Widmann" maintainer="info@goover.de"
LABEL           org.opencontainers.image.source="https://github.com/gOOvER/own-pterodactyl-images"
LABEL           org.opencontainers.image.licenses=MIT

## install required packages
RUN             dpkg --add-architecture i386
RUN             apt update
RUN             apt -y upgrade
RUN             apt install -y --no-install-recommends \
                    alsa-tools \
                    dbus \
                    firmware-sof-signed \
                    gnupg \
                    gnupg2 \
                    gnutls-bin \
                    iproute2 \
                    locales \
                    musl-dev \
                    netcat-openbsd \
                    numactl \
                    python3 \
                    software-properties-common \
                    wget \
                    winbind \
                    xauth \
                    xvfb \
                    lib32gcc-s1 \
                    libao-common \
                    libasound2 \
                    libasound2 \
                    libgdiplus \
                    libncurses5-dev:i386 \
                    libncurses6 \
                    libntlm0 \
                    libpulse-dev
            

# Install wine and with recommends
RUN             mkdir -pm755 /etc/apt/keyrings
RUN             wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key
RUN             wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/debian/dists/bookworm/winehq-bookworm.sources
RUN             apt update
RUN             apt install --install-recommends winehq-stable cabextract -y

# Set up Winetricks
RUN	            wget -q -O /usr/sbin/winetricks https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks
RUN             chmod +x /usr/sbin/winetricks

ENV             HOME=/home/container
ENV             WINEPREFIX=/home/container/.wine
ENV             WINEDLLOVERRIDES="mscoree,mshtml=n,b"
ENV             DISPLAY=:0
ENV             DISPLAY_WIDTH=1024
ENV             DISPLAY_HEIGHT=768
ENV             DISPLAY_DEPTH=16

## Setup user and working directory
RUN             useradd -m -d /home/container -s /bin/bash container
USER            container
ENV             USER=container HOME=/home/container
WORKDIR         /home/container

COPY            ./entrypoint.sh /entrypoint.sh
CMD	            ["/bin/bash", "/entrypoint.sh"]
