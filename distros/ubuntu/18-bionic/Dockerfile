FROM            --platform=$TARGETOS/$TARGETARCH ubuntu:18.04

LABEL           author="Torsten Widmann" maintainer="info@goover.de"
LABEL           org.opencontainers.image.source="https://github.com/gOOvER/own-pterodactyl-images"
LABEL           org.opencontainers.image.licenses=MIT

ENV             DEBIAN_FRONTEND noninteractive

## update base packages
RUN             apt update \
                && apt -y upgrade

## install dependencies
RUN             apt install -y \
                        apt-transport-https \
                        binutils \
                        bzip2 \
                        cabextract \
                        curl \
                        ffmpeg \
                        g++ \
                        gcc \
                        gdb \
                        git \
                        icu-devtools \
                        init-system-helpers \
                        iproute2 \
			locales \
                        net-tools \
                        netcat \
                        sqlite3 \
                        tar \
                        telnet \
                        unzip \
                        wget \
                        xz-utils \
                        zip \
                        zlib1g \
                        lib32gcc1 \
                        libatomic1 \
                        libc++-dev \
                        libc6 \
                        libcurl3-gnutls \
                        libduktape202 \
                        libfluidsynth1 \
                        libfontconfig \
                        libgcc1 \
                        libicu60 \
                        libiculx60 \
                        libjsoncpp1 \
                        libleveldb1v5 \
                        liblua5.1-0 \
                        libluajit-5.1-2 \
                        liblzo2-2 \
                        libmariadbclient-dev \
                        libsdl1.2debian \
                        libsdl2-2.0-0 \
                        libsqlite3-0 \
                        libsqlite3-dev \
                        libssl1.0-dev \
                        libssl1.0.0 \
                        libunwind8 \
                        libzip4

## configure locale
RUN             update-locale lang=en_US.UTF-8 \
                && dpkg-reconfigure --frontend noninteractive locales

## Setup user and working directory
RUN             useradd -m -d /home/container -s /bin/bash container
USER            container
ENV             USER=container HOME=/home/container
WORKDIR         /home/container

COPY            ./../entrypoint.sh /entrypoint.sh
CMD             ["/bin/bash", "/entrypoint.sh"]
