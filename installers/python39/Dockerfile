FROM        --platform=$BUILDPLATFORM python:3.9-slim-bookworm

LABEL           author="Torsten Widmann" maintainer="info@goover.de"
LABEL           org.opencontainers.image.source="https://github.com/gOOvER/own-pterodactyl-images"
LABEL           org.opencontainers.image.licenses=MIT

## update base packages
ARG             DEBIAN_FRONTEND noninteractive
RUN         	dpkg --add-architecture i386
RUN             apt update \
                && apt -y upgrade

RUN		 		apt install -y --no-install-recommends \
						build-essential \
						ca-certificates \
						curl \
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
						lib32gcc-s1 \
						libcurl4 \
						libcurl4:i386 \
						libcurl4-gnutls-dev \
						libcurl4-gnutls-dev:i386 \
						libsdl2-2.0-0 \
						libsdl2-2.0-0:i386
