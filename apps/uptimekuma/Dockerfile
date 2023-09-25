FROM        --platform=$TARGETOS/$TARGETARCH node:18-alpine

LABEL       author="Torsten Widmann" maintainer="info@goover.de"
LABEL       org.opencontainers.image.source="https://github.com/gOOvER/own-pterodactyl-images"
LABEL       org.opencontainers.image.licenses=MIT

RUN         apk update \
            && apk upgrade

RUN         apk add --no-cache \
                autoconf \
                automake \
                build-essential \
                ca-certificates\
                curl \
                bind-tools \
				ffmpeg \
                g++ \
                git \
                gpg \
                gnupg \
                iproute2 \
                iputils-ping \
                libtool \
                python3 \
                python3-dev \
                sqlite \
                tzdata \
                zip

# updating npm 
RUN         npm install npm@latest -g

# add cloudflare repo
RUN         curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o /usr/bin/cloudflared

## Setup user and working directory
RUN         useradd -m -d /home/container -s /bin/bash container
USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

COPY        ./entrypoint.sh /entrypoint.sh
CMD         ["/bin/bash", "/entrypoint.sh"]
