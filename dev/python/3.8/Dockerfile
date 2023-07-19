FROM        --platform=$TARGETOS/$TARGETARCH python:3.8-slim

LABEL       author="Michael Parker" maintainer="parker@pterodactyl.io"

# Sets the default stop signal as wings can (currently) only send a kill or generic stop
STOPSIGNAL SIGINT

RUN         apt update \
            && apt -y install git gcc g++ ca-certificates dnsutils curl iproute2 ffmpeg procps default-libmysqlclient-dev \
            && useradd -d /home/container -m container
RUN         python3 -m pip install --upgrade pip

USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

COPY        ./../entrypoint.sh /entrypoint.sh
CMD         ["/bin/bash", "/entrypoint.sh"]
