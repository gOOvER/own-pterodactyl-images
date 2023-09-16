FROM        --platform=$TARGETOS/$TARGETARCH eqalpha/keydb:latest

LABEL       author="Torsten Widmann" maintainer="info@goover.de"
LABEL       org.opencontainers.image.source="https://github.com/gOOvER/own-pterodactyl-images"
LABEL       org.opencontainers.image.licenses=MIT

ENV         DEBIAN_FRONTEND noninteractive
RUN         apt update \
             && apt -y upgrade

RUN     apt -y install --install-recommends \
                iproute2 \
                wget \
                curl \
                lsb-release

## Setup user and working directory
RUN     useradd -m -d /home/container -s /bin/bash container
USER    container
ENV     USER=container HOME=/home/container
WORKDIR /home/container

COPY    ./entrypoint.sh /entrypoint.sh
CMD     ["/bin/bash", "/entrypoint.sh"]