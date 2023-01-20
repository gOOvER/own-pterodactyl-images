FROM        --platform=$TARGETOS/$TARGETARCH eclipse-temurin:11-jdk-focal

LABEL org.opencontainers.image.authors="info@goover.de"
LABEL version="1.0"
LABEL description="Pterodactyl image for CorvinBot"

## install basic reqs
RUN          apt update \         
                && apt install -y git libtool netcat ffmpeg iproute2 curl gnupg sudo

## install mongo
RUN         wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | apt-key add - \
                && echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/6.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-6.0.list \
                && apt update \
                && apt install -y mongodb-org mongodb-org-server mongodb-org-shell mongodb-org-mongos mongodb-org-tools

## install nodejs
RUN         curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash - \
                && curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | tee /usr/share/keyrings/yarnkey.gpg >/dev/null \
                && echo "deb [signed-by=/usr/share/keyrings/yarnkey.gpg] https://dl.yarnpkg.com/debian stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN         apt update \
                && apt install -y nodejs yarn \
                && npm install -g npm@latest

## add container user
RUN         useradd -d /home/container -m container -s /bin/bash

USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

COPY        ./entrypoint.sh /entrypoint.sh
CMD         ["/bin/bash", "/entrypoint.sh"]