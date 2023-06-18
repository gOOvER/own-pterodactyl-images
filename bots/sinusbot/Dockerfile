FROM        --platform=$TARGETOS/$TARGETARCH debian:bookworm-slim

LABEL       maintainer="info@goover.de>" version="1.0"

ENV         DEBIAN_FRONTEND noninteractive

# Install Dependencies
RUN         apt update \
                && apt upgrade -y \
                && apt install -y ca-certificates less locales pulseaudio python3 sudo x11vnc x11-xkb-utils xvfb iproute2 ffmpeg curl \
			    libasound2 libegl1-mesa libglib2.0-0 libnss3 libpci3 libpulse0 libxcursor1 libxslt1.1 libx11-xcb1 libxkbcommon0 \
                && useradd -m -d /home/container container

RUN         curl -L https://yt-dl.org/downloads/latest/youtube-dl -o /usr/local/bin/youtube-dl \
            && chmod a+rx /usr/local/bin/youtube-dl
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

USER        container    
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

COPY        ./entrypoint.sh /entrypoint.sh
CMD         ["/bin/bash", "/entrypoint.sh"]
