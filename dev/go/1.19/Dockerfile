FROM        --platform=$BUILDPLATFORM golang:1.19-alpine

LABEL       author="Matthew Penner" maintainer="matthew@pterodactyl.io"
LABEL       org.opencontainers.image.licenses=AGPL

RUN         apk add --update --no-cache ca-certificates tzdata \
				&& adduser -D -h /home/container container

USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

COPY        ./../entrypoint.sh /entrypoint.sh
CMD         [ "/bin/ash", "/entrypoint.sh" ]
