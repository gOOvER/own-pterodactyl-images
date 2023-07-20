FROM        --platform=$TARGETOS/$TARGETARCH mongo:6-jammy

LABEL org.opencontainers.image.authors="info@goover.de"
LABEL version="1.0"
LABEL description="Pterodactyl image for Screeps"

## install basic reqs
RUN          apt update \         
                && apt install -y git libtool netcat ffmpeg iproute2 curl gnupg software-properties-common build-essential tcl git lsb-release

## install nodejs
RUN         curl -fsSL https://deb.nodesource.com/setup_10.x | bash - \
                && curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | tee /usr/share/keyrings/yarnkey.gpg >/dev/null \
                && echo "deb [signed-by=/usr/share/keyrings/yarnkey.gpg] https://dl.yarnpkg.com/debian stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN         apt update \
                && apt install -y nodejs yarn \
                && npm install -g npm@latest

## install redis
RUN         curl -fsSL https://packages.redis.io/gpg | gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg
RUN         echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/redis.list
RUN         apt update
RUN         apt install -y redis                

## Setup user and working directory
RUN         useradd -m -d /home/container -s /bin/bash container
USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

COPY        ./entrypoint.sh /entrypoint.sh
CMD         ["/bin/bash", "/entrypoint.sh"]