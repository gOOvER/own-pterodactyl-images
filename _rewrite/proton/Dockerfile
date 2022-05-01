FROM        --platform=$BUILDPLATFORM debian:stable-slim

LABEL       author="Torsten Widmann" maintainer="info@goover.de"
# Setting up an alias to launch Steam easily.
#RUN         su proton -c "echo 'alias steam=\"/usr/games/steam\"' >> /home/container/.bashrc"

ARG         DEBIAN_FRONTEND=noninteractive

RUN         dpkg --add-architecture i386
RUN         apt update 
RUN         apt install -y --no-install-recommends gpg-agent software-properties-common apt-transport-https wget
RUN     	wget https://steamcdn-a.akamaihd.net/client/installer/steam.deb
RUN         apt install -y ./steam.deb

USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

COPY        ./entrypoint.sh /entrypoint.sh
CMD         [ "/bin/bash", "/entrypoint.sh" ]