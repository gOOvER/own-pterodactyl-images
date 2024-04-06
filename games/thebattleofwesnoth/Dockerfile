FROM  --platform=$TARGETOS/$TARGETARCH ubuntu:22.04

LABEL author="Michael Parker" maintainer="parker@pterodactyl.io"

ARG DEBIAN_FRONTEND noninteractive

# update base packages
RUN   apt update \
        &&   apt upgrade -y

# install dependencies
RUN   apt install -y \
        cmake \
        g++ \
        gcc \
        gdb \
        git \
        openssl \
        tar \
        tini \ 
        unzip \
        zip \
        zlib1g-dev \
        libboost-coroutine-dev \
        libboost-filesystem-dev \
        libboost-graph-dev \
        libboost-iostreams-dev \
        libboost-locale-dev \
        libboost-program-options-dev \
        libboost-random-dev \
        libboost-regex-dev \
        libboost-system-dev \
        libbz2-dev \
        libc++-dev \
        libc6 \
        libcairo2-dev \
        libcrypto++-dev \
        libcurl4-openssl-dev \
        libgcc1 \
        libsdl-pango-dev \
        libsdl2-dev \
        libsdl2-image-dev \
        libsdl2-mixer-dev \
        libssl-dev \
        libvorbis-dev \

# configure locale
RUN   update-locale lang=en_US.UTF-8 \
        &&   dpkg-reconfigure --frontend noninteractive locales

## add container user
RUN   useradd -m -d /home/container -s /bin/bash container
USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

STOPSIGNAL SIGINT

COPY        --chown=container:container ./entrypoint.sh /entrypoint.sh
RUN         chmod +x /entrypoint.sh
ENTRYPOINT    ["/usr/bin/tini", "-g", "--"]
CMD         ["/entrypoint.sh"]