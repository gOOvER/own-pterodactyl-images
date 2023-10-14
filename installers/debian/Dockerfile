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
						libcurl4-gnutls \
						libcurl4-gnutls:i386 \
						libsdl2-2.0-0 \
						libsdl2-2.0-0:i386

RUN 			ln -s /usr/lib/x86_64-linux-gnu/libcurl.so.4 /usr/lib/x86_64-linux-gnu/libcurl.so
