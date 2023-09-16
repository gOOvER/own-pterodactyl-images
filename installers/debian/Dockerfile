FROM        --platform=$BUILDPLATFORM debian:stable-slim

LABEL           author="Torsten Widmann" maintainer="info@goover.de"
LABEL           org.opencontainers.image.source="https://github.com/gOOvER/own-pterodactyl-images"
LABEL           org.opencontainers.image.licenses=MIT

ENV             DEBIAN_FRONTEND noninteractive

## update base packages
RUN             apt update \
                && apt -y upgrade

RUN         dpkg --add-architecture i386

RUN 		apt -y --no-install-recommends install \
					ca-certificates \
					curl \
					git \
					tar \
					unzip \
					wget \
					lib32gcc-s1 \
					libsdl2-2.0-0:i386
