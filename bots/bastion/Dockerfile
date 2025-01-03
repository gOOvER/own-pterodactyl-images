FROM        --platform=$TARGETOS/$TARGETARCH mongo:6-jammy

LABEL       org.opencontainers.image.authors="info@goover.de"
LABEL       org.opencontainers.image.source="https://github.com/gOOvER/own-pterodactyl-images"
LABEL       org.opencontainers.image.licenses=AGPL-3.0-or-later
LABEL       org.opencontainers.image.description "Docker image for Pelican Hosting Panel and Pterodactyl"


## install nodejs 18
RUN             apt update \
                && apt upgrade -y \
                && apt install --no-install-recommends -y curl \ 
                && curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
                && apt install -y nodejs \
                && npm install -g npm@latest \
                && apt install -y python3 build-essential git libtool netcat ffmpeg iproute2 tzdata

RUN             useradd -d /home/container -m container -s /bin/bash

USER            container
ENV             USER=container HOME=/home/container
WORKDIR         /home/container

COPY            ./entrypoint.sh /entrypoint.sh
CMD             ["/bin/bash", "/entrypoint.sh"]