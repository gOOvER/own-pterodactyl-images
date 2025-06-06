FROM    	debian:buster-slim

LABEL       org.opencontainers.image.authors="Torsten Widmann - gOOvER - info@goover.de"
LABEL       org.opencontainers.image.source="https://github.com/gOOvER/own-pterodactyl-images"
LABEL       org.opencontainers.image.description="Docker image for Pelican, Jexactyl & Pterodactyl"
LABEL       org.opencontainers.image.licenses=AGPL-3.0-or-later

ARG 		DEBIAN_FRONTEND noninteractive

## update base packages
RUN     	apt update \
        		&& apt -y upgrade

## install dependencies
RUN     	apt install -y \
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
                git-lfs \
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
                libprotobuf17 \
                libsdl1.2debian \
                libsdl2-2.0-0 \
                libsqlite3-dev \
                libssl-dev \
                libunwind8 \
                libz-dev

## configure locale
RUN     	update-locale lang=en_US.UTF-8 \
         		&& dpkg-reconfigure --frontend noninteractive locales

## Setup user and working directory
RUN     useradd -m -d /home/container -s /bin/bash container
USER    container
ENV     USER=container HOME=/home/container
WORKDIR /home/container

COPY    ./../entrypoint.sh /entrypoint.sh
CMD     ["/bin/bash", "/entrypoint.sh"]
