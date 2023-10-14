FROM        --platform=$TARGETOS/$TARGETARCH mongo:6-jammy

LABEL           author="Torsten Widmann" maintainer="info@goover.de"
LABEL           org.opencontainers.image.source="https://github.com/gOOvER/own-pterodactyl-images"
LABEL           org.opencontainers.image.licenses=MIT

RUN         apt update \
             && apt -y upgrade

RUN         apt install -y \
                    build-essential \
                    curl \
                    ffmpeg \
                    git \
                    gnupg \
                    iproute2 \
                    libtool \
                    lsb-release \
                    netcat \
                    software-properties-common \
                    tcl

## install nodejs
RUN         mkdir -p /etc/apt/keyrings \
            && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg

RUN         echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_16.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list
RUN         apt update

RUN         apt install -y nodejs \
RUN         npm install -g npm@latest

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