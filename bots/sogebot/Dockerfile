#
# sogeBot Install Image
#

FROM        --platform=$BUILDPLATFORM node:18-bullseye-slim

LABEL       author="Torsten Widmann" maintainer="info@goover.de"
LABEL       org.opencontainers.image.source="https://github.com/PteroForge/pterodactyl-images"
LABEL       org.opencontainers.image.licenses=MIT

RUN         apt update \
            && apt -y install ffmpeg iproute2 git sqlite3 libsqlite3-dev python3 python3-dev ca-certificates dnsutils tzdata zip libnss3 libtool autoconf automake g++ libtool build-essential \
            && useradd -d /home/container -m container

RUN         npm install npm@latest -g

USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

COPY        ./../entrypoint.sh /entrypoint.sh
CMD         ["/bin/bash", "/entrypoint.sh"]