FROM        node:16-bullseye-slim

LABEL       author="Torsten Widmann" maintainer="info@goover.de"

RUN         apt update \
            && apt -y install curl unzip jq wget ffmpeg iproute2 git sqlite3 libsqlite3-dev python3 python3-dev build-essential ca-certificates dnsutils tzdata zip \
            && useradd -m -d /home/container container

RUN         npm install -g npm@latest

USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

COPY        ./entrypoint.sh /entrypoint.sh
CMD         ["/bin/bash", "/entrypoint.sh"]
