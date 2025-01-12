FROM        --platform=$TARGETOS/$TARGETARCH mongo:7-jammy

LABEL       org.opencontainers.image.description="STEAM Proton-GE Image to use with Pelican/Pterodactyl Gamepanel"
LABEL       org.opencontainers.image.authors="info@goover.de"
LABEL       org.opencontainers.image.source="https://github.com/gOOvER/own-pterodactyl-images"
LABEL       org.opencontainers.image.licenses=AGPL-3.0-or-later


## install nodejs 18
RUN             apt update \
                && apt upgrade -y \
                && apt install --no-install-recommends -y curl \
                && curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
                && apt install -y nodejs \
                && npm install -g npm@next-10 \
                && apt install -y python3 build-essential git libtool netcat ffmpeg iproute2 tzdata

RUN             useradd -d /home/container -m container -s /bin/bash

USER            container
ENV             USER=container HOME=/home/container
WORKDIR         /home/container

COPY            ./entrypoint.sh /entrypoint.sh
CMD             ["/bin/bash", "/entrypoint.sh"]
