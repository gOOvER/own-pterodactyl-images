FROM        --platform=$BUILDPLATFORM debian:stable-slim

LABEL           author="Torsten Widmann" maintainer="info@goover.de"
LABEL           org.opencontainers.image.source="https://github.com/gOOvER/own-pterodactyl-images"
LABEL           org.opencontainers.image.licenses=MIT

## update base packages
ENV             DEBIAN_FRONTEND noninteractive
RUN             apt update \
                && apt -y upgrade

RUN		 		apt -y --no-install-recommends install \
						ca-certificates \
						curl \
						git \
						tar \
						unzip \
						wget \
						lib32gcc-s1 \
						libsdl2-2.0-0 \
						libsdl2-2.0-0:i386
