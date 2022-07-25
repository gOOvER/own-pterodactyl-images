# ----------------------------------
# Environment: keydb
# ----------------------------------
FROM    eqalpha/keydb:latest

LABEL   author="Torsten Widmann" maintainer="info@goover.de"

ENV     DEBIAN_FRONTEND noninteractive

RUN     apt -y update && \
        apt -y upgrade && \
        apt -y install --install-recommends iproute2 wget curl lsb-release

RUN     useradd -d /home/container -m container -s /bin/bash

USER    container
ENV     USER=container HOME=/home/container
WORKDIR /home/container

COPY    ./entrypoint.sh /entrypoint.sh
CMD     ["/bin/bash", "/entrypoint.sh"]