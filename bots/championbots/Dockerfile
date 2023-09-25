FROM        --platform=$TARGETOS/$TARGETARCH mongo:6-jammy

LABEL       author="Torsten Widmann" maintainer="info@goover.de"
LABEL       org.opencontainers.image.source="https://github.com/gOOvER/own-pterodactyl-images"
LABEL       org.opencontainers.image.licenses=MIT

## install basic reqs
RUN         apt update \         
            && apt install -y \
                  ca-certificates \
                  curl \
                  ffmpeg \
                  git \
                  gnupg \
                  iproute2 \
                  libtool \
                  netcat \
                  software-properties-common \
                  tzdata

## install nodejs & yarn
RUN         mkdir -p /etc/apt/keyrings \
                && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
                && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_18.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list \
                && curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
                && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

RUN         apt update \
                && apt install -y nodejs yarn

RUN         npm install npm@latest -g
RUN         npm install -g typescript ts-node

## add container user
RUN         useradd -d /home/container -m container -s /bin/bash
USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

COPY        ./entrypoint.sh /entrypoint.sh
CMD         ["/bin/bash", "/entrypoint.sh"]