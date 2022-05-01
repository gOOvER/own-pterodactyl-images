FROM        ubuntu:18.04

LABEL maintainer="ki2007 <ki2007@damw.eu>" version="1.0"

ENV         DEBIAN_FRONTEND noninteractive

# Install Dependencies
RUN         apt update \
            && apt upgrade -y \
            && apt install -y ca-certificates curl less libasound2 libegl1-mesa libglib2.0-0 libnss3 libpci3 libpulse0 libxcursor1 libxslt1.1 libx11-xcb1 libxkbcommon0 locales pulseaudio python python3 sudo x11vnc x11-xkb-utils xvfb iproute2 \
            && curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp \
            && chmod a+rx /usr/local/bin/yt-dlp \
            && useradd -m -d /home/container container

ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

COPY        ./entrypoint.sh /entrypoint.sh
CMD         ["/bin/bash", "/entrypoint.sh"]
