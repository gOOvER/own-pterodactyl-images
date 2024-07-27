FROM        --platform=$TARGETOS/$TARGETARCH alpine:latest

LABEL       author="Torsten Widmann" maintainer="info@goover.de"
LABEL       org.opencontainers.image.source="https://github.com/gOOvER/own-pterodactyl-images"
LABEL       org.opencontainers.image.licenses=MIT
LABEL       org.opencontainers.image.description Dockerimage for Pelican Hosting Panel and PterodactylLABEL       org.opencontainers.image.description Dockerimage for Pelican Hosting Panel and Pterodactyl

# Install wine and wget
RUN         apk update
RUN         apk upgrade
RUN         apk add --no-cache tzdata xvfb wget curl git
RUN         apk add wine --update-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/community --allow-untrusted
RUN         apk add winetricks --update-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing/ --allow-untrusted

# ENV
ENV         HOME=/home/container
ENV         WINEPREFIX=/home/container/.wine
ENV         WINEDLLOVERRIDES="mscoree,mshtml="
ENV         DISPLAY=:0
ENV         DISPLAY_WIDTH=1024
ENV         DISPLAY_HEIGHT=768
ENV         DISPLAY_DEPTH=16

## Setup user and working directory
RUN         adduser -D -h /home/container container -s /bin/bash container
USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

#
COPY        ./entrypoint.sh /entrypoint.sh
CMD	        ["/bin/ash", "/entrypoint.sh"]
