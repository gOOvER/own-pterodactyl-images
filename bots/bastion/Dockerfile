FROM        --platform=$TARGETOS/$TARGETARCH mongo:6-jammy

LABEL       author="Torsten Widmann" maintainer="info@goover.de"
LABEL       org.opencontainers.image.source="https://github.com/gOOvER/own-pterodactyl-images"
LABEL       org.opencontainers.image.licenses=AGPL
LABEL       org.opencontainers.image.description Dockerimage for Pelican Hosting Panel and PterodactylLABEL       org.opencontainers.image.description Dockerimage for Pelican Hosting Panel and Pterodactyl

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