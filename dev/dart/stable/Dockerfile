FROM        --platform=$TARGETOS/$TARGETARCH dart:stable

LABEL       org.opencontainers.image.authors="info@goover.de"
LABEL       org.opencontainers.image.source="https://github.com/gOOvER/own-pterodactyl-images"
LABEL       org.opencontainers.image.licenses=AGPL-3.0-or-later
LABEL       org.opencontainers.image.description="Docker image for Pelican Hosting Panel and Pterodactyl"
ENV         DEBIAN_FRONTEND noninteractive
RUN         apt update \
             && apt -y upgrade

RUN 		 apt install -y \
				curl \
				ca-certificates \
				openssl \
				git \
				locales \
				tar \
				sqlite3 \
				fontconfig \
				tzdata \
				iproute2 \
				libfreetype6 \
				font-manager \
				ipset

## Configure locale
RUN          update-locale lang=en_US.UTF-8 \
             && dpkg-reconfigure --frontend noninteractive locales

## Setup user and working directory
RUN             useradd -m -d /home/container -s /bin/bash container
USER            container
ENV             USER=container HOME=/home/container
WORKDIR         /home/container

COPY        ./../entrypoint.sh /entrypoint.sh
CMD         [ "/bin/bash", "/entrypoint.sh" ]
