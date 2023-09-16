FROM    --platform=$TARGETOS/$TARGETARCH redis:6-bookworm

LABEL   author="Torsten Widmann" maintainer="info@goover.de"
LABEL   org.opencontainers.image.source="https://github.com/gOOvER/own-pterodactyl-images"
LABEL   org.opencontainers.image.licenses=MIT

ENV     DEBIAN_FRONTEND noninteractive
RUN     apt update \
        && apt -y upgrade

RUN     apt -y install \
                iproute2

## Setup user and working directory
RUN     useradd -m -d /home/container -s /bin/bash container
USER    container
ENV     USER=container HOME=/home/container
WORKDIR /home/container

COPY    ./entrypoint.sh /entrypoint.sh
CMD     ["/bin/bash", "/entrypoint.sh"]