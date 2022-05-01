FROM        --platform=$BUILDPLATFORM archlinux:base

LABEL       author="Torsten Widmann" maintainer="info@goover.de"

RUN 		pacman -Fy --noconfirm
RUN 		pacman -Syu --noconfirm
RUN         pacman -Sy --noconfirm ca-certificates tzdata

RUN 		adduser -D -h /home/container container

USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

COPY        ./../entrypoint.sh /entrypoint.sh
CMD         [ "/bin/ash", "/entrypoint.sh" ]
