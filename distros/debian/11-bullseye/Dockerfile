FROM    --platform=$TARGETOS/$TARGETARCH debian:bullseye-slim

LABEL   author="Torsten Widmann" maintainer="info@goover.de"
LABEL   org.opencontainers.image.source="https://github.com/gOOvER/own-pterodactyl-images"
LABEL   org.opencontainers.image.licenses=MIT

ENV     DEBIAN_FRONTEND noninteractive

## update base packages
RUN     apt update \
        && apt -y upgrade

## Install dependencies
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
            netcat-openbsd \
            rapidjson-dev \
            software-properties-common \
            sqlite3 \
            tar \
            telnet libatomic1 \
            tzdata \
            unzip \
            wget \
            xz-utils \
            zip \
            libc++-dev \
            libc6 \
            libduktape205 \
            libfluidsynth2 \
            libfontconfig \
            libgcc1 \
            libicu67 \
            liblua5.4-0 \
            liblzo2-2 \
            libmariadbclient-dev-compat \
            libprotobuf23 \
            libsdl1.2debian \
            libsdl2-2.0-0 \
            libsqlite3-dev \
            libssl-dev \
            libstdc++6 \
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