FROM    --platform=$TARGETOS/$TARGETARCH debian:buster-slim

LABEL   author="Torsten Widmann" maintainer="info@goover.de"
LABEL   org.opencontainers.image.source="https://github.com/gOOvER/own-pterodactyl-images"
LABEL   org.opencontainers.image.licenses=MIT

ENV     DEBIAN_FRONTEND noninteractive

## update base packages
RUN     apt update \
        && apt -y upgrade

## install dependencies
RUN     apt install -y \
                apt-transport-https \
                binutils \
                ca-certificates \
                cabextract \
                curl \
                ffmpeg \
                g++ \
                gcc \
		gdb \
                git \
                gnupg2 \
                icu-devtools \
                iproute2 \
		locales \
                net-tools \
                netcat \
                rapidjson-dev \
                software-properties-common \
                sqlite3 \
                tar \
                telnet \
                tzdata \
                unzip \
                wget \
                xz-utils \
                zip \
                lib32gcc1 \
                libatomic1 \
                libc++-dev \
                libc6 \
                libduktape203 \
                libfontconfig \
                libgcc1 \
                libicu63 \
                liblua5.3 \
                liblzo2-2 \
                libmariadbclient-dev \
                libsdl1.2debian \
                libsdl2-2.0-0 \
                libsqlite3-dev \
                libssl-dev \
                libunwind8 \
                libz-dev

## configure locale
RUN     update-locale lang=en_US.UTF-8 \
         && dpkg-reconfigure --frontend noninteractive locales

## Setup user and working directory
RUN     useradd -m -d /home/container -s /bin/bash container
USER    container
ENV     USER=container HOME=/home/container
WORKDIR /home/container

COPY    ./../entrypoint.sh /entrypoint.sh
CMD     ["/bin/bash", "/entrypoint.sh"]