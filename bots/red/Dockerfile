FROM        python:3.10-slim

LABEL       author="Michael Parker" maintainer="parker@pterodactyl.io"

RUN         mkdir -p /usr/share/man/man1

RUN         apt update \
            && apt -y upgrade \
            && apt -y install \
                   git \
                   ca-certificates \
                   dnsutils \
                   iproute2 \
                   wget \
                   curl \
                   xz-utils \
                   default-jre-headless \
                   netcat-openbsd \
                   zlib1g-dev \
                   libffi-dev \
                   libmagickwand-dev \
                   unzip \
                   libaa1-dev \
                   build-essential \
                   tk-dev \
                   libncurses5-dev \
                   libncursesw5-dev \
                   libreadline6-dev \
                   libdb5.3-dev \
                   libgdbm-dev \
                   libsqlite3-dev \
                   libssl-dev \
                   libbz2-dev \
                   libexpat1-dev \
                   liblzma-dev \
                   ffmpeg \
                   imagemagick

RUN     pip install --upgrade pip \
            && pip install python-forecastio tweepy unidecode discord-text-sanitizer mcstatus bs4 sqlalchemy geocoder valve python-valve py-cpuinfo psutil numpy scipy \
            && useradd -m -d /home/container container \
            && mkdir -p /home/container/.config/Red-DiscordBot/ \
            && ln -s /home/container/.config/Red-DiscordBot/ /usr/local/share/Red-DiscordBot

USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

COPY        ./entrypoint.sh /entrypoint.sh
CMD         ["/bin/bash", "/entrypoint.sh"]
