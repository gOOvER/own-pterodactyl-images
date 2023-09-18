FROM        --platform=$TARGETOS/$TARGETARCH debian:bookworm-slim

LABEL   author="Torsten Widmann" maintainer="info@goover.de"
LABEL   org.opencontainers.image.source="https://github.com/gOOvER/own-pterodactyl-images"
LABEL   org.opencontainers.image.licenses=MIT

RUN         useradd -d /home/container -m container

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
RUN         apt install -y java-17-amazon-corretto-jdk

## configure locale
RUN     update-locale lang=en_US.UTF-8 \
         && dpkg-reconfigure --frontend noninteractive locales

## Setup user and working directory
RUN     useradd -m -d /home/container -s /bin/bash container
USER    container
ENV     USER=container HOME=/home/container
WORKDIR /home/container

COPY        ./../entrypoint.sh /entrypoint.sh
CMD         [ "/bin/bash", "/entrypoint.sh" ]
