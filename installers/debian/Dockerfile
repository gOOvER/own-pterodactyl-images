FROM        --platform=$BUILDPLATFORM debian:bookworm-slim

LABEL           author="Torsten Widmann" maintainer="info@goover.de"
LABEL           org.opencontainers.image.source="https://github.com/gOOvER/own-pterodactyl-images"
LABEL           org.opencontainers.image.licenses=MIT

## update base packages
ENV             DEBIAN_FRONTEND noninteractive
RUN         	dpkg --add-architecture i386
RUN             apt update \
                && apt -y upgrade

RUN		 		apt install -y --no-install-recommends \
						ca-certificates \
						curl \
						git \
						git-lfs \
						jq \
						tar \
						unzip \
						wget \
						lib32gcc-s1 \
						lib64gcc-s1 \
						libcurl4 \
						libcurl4:i386 \
						libcurl4-gnutls-dev \
						libcurl4-gnutls-dev:i386 \
						libsdl2-2.0-0 \
						libsdl2-2.0-0:i386
