FROM        debian:bookworm-slim

LABEL       org.opencontainers.image.authors="Torsten Widmann - gOOvER - info@goover.de"
LABEL       org.opencontainers.image.source="https://github.com/gOOvER/own-pterodactyl-images"
LABEL       org.opencontainers.image.description="Docker image for Pelican, Jexactyl & Pterodactyl"
LABEL       org.opencontainers.image.licenses=AGPL-3.0-or-later

## update base packages
ARG         DEBIAN_FRONTEND noninteractive
RUN        	dpkg --add-architecture i386
RUN         apt update \
            && apt -y upgrade

RUN		 	apt install -y --no-install-recommends \
				build-essential \
				ca-certificates \
				curl \
				file \
				git \
				git-lfs \
				jq \
				locales \
				python3 \
               	python3-dev \
               	python3-pip \
				tar \
				unzip \
				wget \
				zstd \
				lib32gcc-s1 \
				libcurl4 \
				libcurl4-gnutls-dev \
				libsdl2-2.0-0

## download lastest 7zip for archives
RUN 	wget https://www.7-zip.org/a/7z2409-linux-x64.tar.xz \
			&& tar xf 7z2409-linux-x64.tar.xz \
			&& mv 7zz /usr/local/bin \
			&& rm -f 7z2409-linux-x64.tar.xz
