FROM        --platform=$TARGETOS/$TARGETARCH python:3.8-slim

LABEL           author="Torsten Widmann" maintainer="info@goover.de"
LABEL           org.opencontainers.image.source="https://github.com/gOOvER/own-pterodactyl-images"
LABEL           org.opencontainers.image.licenses=MIT

ENV             DEBIAN_FRONTEND=noninteractive

RUN             apt update \
                && apt -y upgrade

RUN             apt -y install \
                    ca-certificates \
                    curl \
                    default-libmysqlclient-dev \
                    dnsutils \
                    ffmpeg \
                    g++ \
                    gcc \
                    git \
                    iproute2 \
                    locales \
                    procps

RUN         python -m pip install --upgrade pip

# Set the locale
RUN         sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
            locale-gen
ENV         LANG en_US.UTF-8  
ENV         LANGUAGE en_US:en  
ENV         LC_ALL en_US.UTF-8

## Setup user and working directory
RUN             useradd -m -d /home/container -s /bin/bash container
USER            container
ENV             USER=container HOME=/home/container
WORKDIR         /home/container

COPY        ./../entrypoint.sh /entrypoint.sh
CMD         ["/bin/bash", "/entrypoint.sh"]
