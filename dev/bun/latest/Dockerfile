FROM        --platform=$TARGETOS/$TARGETARCH oven/bun:latest

LABEL       org.opencontainers.image.authors="info@goover.de"
LABEL       org.opencontainers.image.source="https://github.com/gOOvER/own-pterodactyl-images"
LABEL       org.opencontainers.image.licenses=AGPL-3.0-or-later
LABEL       org.opencontainers.image.description="Docker image for Pelican Hosting Panel and Pterodactyl"

ARG         DEBIAN_FRONTEND=noninteractive
RUN         apt update \
             && apt -y upgrade

RUN         apt install -y \
                apt-transport-https \
                build-essential \
                ca-certificates \
                curl \
                dnsutils \
                ffmpeg \
                git \
                iproute2 \
                libsqlite3-dev \
                libtool \
                locales \
                python3 \
                python3-dev \
                sqlite3 \
                tar \
                tini \
                tzdata \
                wget \
                zip

RUN         bun upgrade

# Set the locale
RUN       	sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
           	locale-gen
ENV      	LANG=en_US.UTF-8
ENV        	LANGUAGE=en_US:en
ENV        	LC_ALL=en_US.UTF-8

## Setup user and working directory
RUN         useradd -m -d /home/container -s /bin/bash container
USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

# Sets the default stop signal as wings can (currently) only send a kill or generic stop
STOPSIGNAL SIGINT

COPY        --chown=container:container ../entrypoint.sh /entrypoint.sh
RUN         chmod +x /entrypoint.sh
ENTRYPOINT  ["/usr/bin/tini", "-g", "--"]
CMD         ["/entrypoint.sh"]
