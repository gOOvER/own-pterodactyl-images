FROM        --platform=$BUILDPLATFORM node:18-bookworm-slim

LABEL       author="Torsten Widmann" maintainer="info@goover.de"
LABEL       org.opencontainers.image.source="https://github.com/gOOvER/own-pterodactyl-images"
LABEL       org.opencontainers.image.licenses=AGPL
LABEL       org.opencontainers.image.description Dockerimage for Pelican Hosting Panel and Pterodactyl
RUN         apt update \
            && apt -y upgrade \
            && apt -y install \
                  ffmpeg \
                  iproute2 \
                  git \
                  sqlite3 \
                  libsqlite3-dev \
                  python3 \
                  python3-dev \
                  ca-certificates \
                  dnsutils \
                  tzdata \
                  zip \
                  libnss3 \
                  libtool \
                  autoconf \
                  automake \
                  g++ libtool \
                  build-essential
            
RUN         useradd -d /home/container -m container

RUN         npm install npm@latest -g

USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

COPY        ./entrypoint.sh /entrypoint.sh
CMD         ["/bin/bash", "/entrypoint.sh"]