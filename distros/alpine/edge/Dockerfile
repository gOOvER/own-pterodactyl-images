FROM        --platform=$BUILDPLATFORM alpine:edge

LABEL   	author="Torsten Widmann" maintainer="info@goover.de"
LABEL   	org.opencontainers.image.source="https://github.com/gOOvER/own-pterodactyl-images"
LABEL   	org.opencontainers.image.licenses=MIT

RUN         apk add --update --no-cache \ 
				ca-certificates \
				tzdata 

## Setup user and working directory
RUN         adduser -D -h /home/container container -s /bin/bash container
USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

COPY        ./../entrypoint.sh /entrypoint.sh
CMD         [ "/bin/ash", "/entrypoint.sh" ]
