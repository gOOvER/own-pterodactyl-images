FROM        --platform=$BUILDPLATFORM alpine:edge

LABEL       org.opencontainers.image.authors="Torsten Widmann - gOOvER - info@goover.de"
LABEL       org.opencontainers.image.source="https://github.com/gOOvER/own-pterodactyl-images"
LABEL       org.opencontainers.image.description="Docker image for Pelican, Jexactyl & Pterodactyl"
LABEL       org.opencontainers.image.licenses=AGPL-3.0-or-later

RUN         apk add --update --no-cache \
				ca-certificates \
				tzdata \
				binutils \
                curl \
                g++ \
                gcc \
                gdb \
                git \
                gnupg \
                iproute2 \
                net-tools \
                netcat-openbsd \
                rapidjson-dev \
                sqlite \
            	tar \
                busybox-extras \
                unzip \
                wget \
            	xz \
                zip \
                libatomic \
                libc++-dev \
                libc6-compat \
                fontconfig \
                libgcc \
                icu \
                lua5.4 \
            	lzo \
                libprotobuf \
                sqlite \
				sqlite-dev \
                libssl3 \
                libstdc++ \
                libunwind \
            	zlib-dev

## Community Repo packages
RUN         apk add --update --no-cache \
				cabextract --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community \
				ffmpeg --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community \
				git-lfs --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community \
				duktape --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community \
				fluidsynth --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community \
				sdl2 --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community

## Setup user and working directory
RUN         adduser -D -h /home/container container -s /bin/bash container
USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

COPY        ./../entrypoint.sh /entrypoint.sh
CMD         [ "/bin/ash", "/entrypoint.sh" ]
