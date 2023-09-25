FROM        --platform=$TARGETOS/$TARGETARCH node:16-bookworm-slim

LABEL       author="Torsten Widmann" maintainer="info@goover.de"
LABEL       org.opencontainers.image.source="https://github.com/gOOvER/own-pterodactyl-images"
LABEL       org.opencontainers.image.licenses=MIT

ENV         DEBIAN_FRONTEND=noninteractive

RUN         apt update \
             && apt -y upgrade

RUN         apt -y install \
                autoconf \
                automake \
                build-essential \
                ca-certificates\
                curl \
                dnsutils \
				ffmpeg \
                g++ \
                git \
                iproute2 \
                iputils-ping \
                libtool \
                python3 \
                python3-dev \
                sqlite3 \
                tzdata \
                zip \
				libnss3 \
                libsqlite3-dev

RUN         npm install -g typescript ts-node

# add Yarn
RUN         curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
            && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
            && apt update \
            && apt -y install yarn

## Setup user and working directory
RUN         useradd -m -d /home/container -s /bin/bash container
USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

COPY        ./../entrypoint.sh /entrypoint.sh
CMD         ["/bin/bash", "/entrypoint.sh"]
