FROM        --platform=$TARGETOS/$TARGETARCH ghcr.io/graalvm/jdk-community:20

LABEL       org.opencontainers.image.authors="info@goover.de"
LABEL       org.opencontainers.image.source="https://github.com/gOOvER/own-pterodactyl-images"
LABEL       org.opencontainers.image.description="Docker image for Pelican Hosting Panel and Pterodactyl"
LABEL       org.opencontainers.image.licenses=AGPL-3.0-or-later

RUN 		microdnf clean all
RUN         microdnf update
RUN 		microdnf install -y \
				curl \
				ca-certificates \
				openssl \
				git \
				tar \
				sqlite \
				fontconfig \
				tzdata \
				iproute \
				gcc \
				gcc-c++ \
				freetype \
				libstdc++ \
				lsof \
				glibc-locale-source \
				glibc-langpack-en

RUN 		microdnf clean all

ENV         LC_ALL=en_US.UTF-8
ENV         LANG=en_US.UTF-8
ENV         LANGUAGE=en_US.UTF-8

RUN 		adduser --home-dir /home/container container
USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

COPY        ./entrypoint.sh /entrypoint.sh
CMD         [ "/bin/bash", "/entrypoint.sh" ]
