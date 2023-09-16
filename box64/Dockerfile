FROM        --platform=$TARGETOS/$TARGETARCH debian:bookworm-slim

LABEL       author="QuintenQVD" maintainer="josdekurk@gmail.com"

ENV     DEBIAN_FRONTEND noninteractive

## Update base packages
RUN          apt update \
             && apt upgrade -y

## Install dependencies
RUN          apt install -y \
                apt-transport-https \
                binutils \
                build-essential \
                ca-certificates \
                cabextract \
                cmake \
                curl \
                ffmpeg \
                git \
                gpg \
                gnupg2 \
                icu-devtools \
                iproute2 \
				locales \
                net-tools \
                rapidjson-dev \
                software-properties-common \
                sqlite3 \
                tar \
                tzdata \
                unzip \
                wget \
                xz-utils \
                zip \
                libatomic1 \
                libc++-dev \
				libc6 \
                libduktape207 \
                libevent-dev \
                libfontconfig \
                libgdiplus \
                libicu72 \
                liblzo2-2 \
                libmariadbclient-dev-compat \
                libsdl1.2debian \
                libsdl2-2.0-0 \
                libsdl2-image-2.0-0 \
                libsdl2-mixer-2.0-0 \
                libsqlite3-dev \
                libssl-dev \
                libunwind8 \
				libz-dev \
                libzip4
			 
## Configure locale
RUN          update-locale lang=en_US.UTF-8 \
             && dpkg-reconfigure --frontend noninteractive locales

##Install box64
RUN         wget https://ryanfortner.github.io/box64-debs/box64.list -O /etc/apt/sources.list.d/box64.list \
            && wget -qO- https://ryanfortner.github.io/box64-debs/KEY.gpg | gpg --dearmor -o /etc/apt/trusted.gpg.d/box64-debs-archive-keyring.gpg 

RUN         apt update 
RUN         apt install -y box64

## Setup user and working directory
RUN         useradd -m -d /home/container -s /bin/bash container
USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

COPY    ./entrypoint.sh /entrypoint.sh
CMD     ["/bin/bash", "/entrypoint.sh"]