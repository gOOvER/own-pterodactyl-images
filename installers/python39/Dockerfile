FROM        --platform=$BUILDPLATFORM python:3.9-slim-bookworm

LABEL       org.opencontainers.image.authors="Torsten Widmann - gOOvER - info@goover.de"
LABEL       org.opencontainers.image.source="https://github.com/gOOvER/own-pterodactyl-images"
LABEL       org.opencontainers.image.description="Docker image for Pelican, Jexactyl & Pterodactyl"
LABEL       org.opencontainers.image.licenses=AGPL-3.0-or-later

## update base packages
ARG         DEBIAN_FRONTEND noninteractive
RUN         dpkg --add-architecture i386
RUN         apt update \
           		&& apt -y upgrade

RUN		 	apt install -y --no-install-recommends \
				build-essential \
				ca-certificates \
				curl \
				git \
				git-lfs \
				jq \
				locales \
				tar \
				unzip \
				wget \
				lib32gcc-s1 \
				libcurl4 \
				libcurl4:i386 \
				libcurl4-gnutls-dev \
				libcurl4-gnutls-dev:i386 \
				libsdl2-2.0-0 \
				libsdl2-2.0-0:i386
