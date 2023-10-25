FROM        --platform=$TARGETOS/$TARGETARCH python:3.11-slim

LABEL           author="Torsten Widmann" maintainer="info@goover.de"
LABEL           org.opencontainers.image.source="https://github.com/gOOvER/own-pterodactyl-images"
LABEL           org.opencontainers.image.licenses=MIT

ENV             DEBIAN_FRONTEND=noninteractive

RUN             apt update \
                && apt -y upgrade

RUN             apt -y install \
                    build-essential \
                    ca-certificates \
                    curl \
                    default-libmysqlclient-dev \
                    dnsutils \
                    ffmpeg \
                    g++ \
                    gcc \
                    git \
                    iproute2 \
                    llvm \
                    locales \
                    make \
                    openjdk-17-jre-headless \
                    procps \
                    tk-dev \
                    uuid-dev \
                    wget \
                    xz-utils \
                    zlib1g-dev \
                    libbz2-dev \
                    libffi-dev \
                    libgdbm-dev \
                    liblzma-dev \
                    libncurses5-dev \
                    libreadline-dev \
                    libsqlite3-dev \
                    libssl-dev \
                    libxml2-dev \
                    libxmlsec1-dev

RUN         python -m pip install --upgrade pip

