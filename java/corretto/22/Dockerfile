FROM        --platform=$TARGETOS/$TARGETARCH ubuntu:noble

LABEL       author="Torsten Widmann" maintainer="info@goover.de"
LABEL       org.opencontainers.image.source="https://github.com/gOOvER/own-pterodactyl-images"
LABEL       org.opencontainers.image.licenses=MIT
LABEL       org.opencontainers.image.description Dockerimage for Pelican Hosting Panel and Pterodactyl
ARG         DEBIAN_FRONTEND=noninteractive

RUN 		apt update -y
RUN         apt -y upgrade
RUN         apt install -y \
                apt-transport-https \
                apt-utils \
                ca-certificates \
                curl \
                fontconfig \
                git \
                gnupg2 \
                iproute2 \
                java-common \
                locales \
                openssl \
                procps \
                software-properties-common \
                sqlite3 \
                tar \
                tzdata \
                wget \
                libfreetype6

RUN         wget -O- -q https://apt.corretto.aws/corretto.key | apt-key add -
RUN         add-apt-repository 'deb https://apt.corretto.aws stable main'
RUN         apt update
RUN         apt install -y java-21-amazon-corretto-jdk

## configure locale
RUN         sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
            locale-gen
ENV         LANG en_US.UTF-8  
ENV         LANGUAGE en_US:en  
ENV         LC_ALL en_US.UTF-8 

## Setup user and working directory
RUN         useradd -m -d /home/container -s /bin/bash container
USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

COPY        ./../entrypoint.sh /entrypoint.sh
CMD         [ "/bin/bash", "/entrypoint.sh" ]
