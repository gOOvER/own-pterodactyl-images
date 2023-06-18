FROM        --platform=$TARGETOS/$TARGETARCH mongo:6-jammy

LABEL       author="Torsten Widmann" maintainer="info@goover.de"
LABEL       org.opencontainers.image.source="https://github.com/gOOvER/own-pterodactyl-images"
LABEL       org.opencontainers.image.licenses=MIT

## install basic reqs
RUN          apt update \         
                && apt install -y \
                      git \
                      libtool \
                      netcat \
                      ffmpeg \
                      iproute2 \
                      curl \
                      gnupg \
                      software-properties-common

## install nodejs
RUN         curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
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