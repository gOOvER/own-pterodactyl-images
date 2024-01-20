FROM        --platform=$TARGETOS/$TARGETARCH node:20-bookworm-slim

LABEL           author="Torsten Widmann" maintainer="info@goover.de"
LABEL           org.opencontainers.image.source="https://github.com/gOOvER/own-pterodactyl-images"
LABEL           org.opencontainers.image.licenses=MIT

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
                file \
                g++ \
                gcc \
                git \
                git-lfs \
                gpg \
                gnupg2 \
                iproute2 \
                iputils-ping \
                jq \
                libtool \
                make \
                python3 \
                python3-dev \
                sqlite3 \
                tzdata \
                zip \
                unzip \
				libnss3 \
                libsqlite3-dev

# updating npm 
RUN         npm install npm@latest -g
RUN         npm install tsc typescript ts-node @types/node --location=global
