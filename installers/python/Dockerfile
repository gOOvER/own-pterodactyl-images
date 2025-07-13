FROM        --platform=$TARGETOS/$TARGETARCH python:3.12-slim

LABEL       org.opencontainers.image.authors="Torsten Widmann - gOOvER - info@goover.de"
LABEL       org.opencontainers.image.source="https://github.com/gOOvER/own-pterodactyl-images"
LABEL       org.opencontainers.image.description="Docker image for Pelican, Jexactyl & Pterodactyl"
LABEL       org.opencontainers.image.licenses=AGPL-3.0-or-later

ARG 		DEBIAN_FRONTEND=noninteractive

RUN         apt update \
		        && apt -y upgrade

RUN         apt -y install --no-install-recommends \
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
				pipx \
                procps \
                tk-dev \
                uuid-dev \
				unzip \
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

RUN         rm -rf /var/lib/apt/lists/*

RUN         python -m pip install --upgrade pip
RUN 	    pip install itch-dl

