# ----------------------------------
# Environment: keydb
# ----------------------------------
FROM    debian:bullseye-slim

LABEL   author="Torsten Widmann" maintainer="info@goover.de"

ENV     DEBIAN_FRONTEND noninteractive

RUN     apt -y update && \
        apt -y upgrade && \
        apt -y install --install-recommends iproute2 wget curl lsb-release systemd

RUN     echo "deb https://download.keydb.dev/open-source-dist $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/keydb.list
RUN     wget -O /etc/apt/trusted.gpg.d/keydb.gpg https://download.keydb.dev/open-source-dist/keyring.gpg
RUN     apt -y update
RUN     apt -y install keydb-server
RUN     useradd -d /home/container -m container -s /bin/bash

USER    container
ENV     USER=container HOME=/home/container
WORKDIR /home/container

COPY    ./entrypoint.sh /entrypoint.sh
CMD     ["/bin/bash", "/entrypoint.sh"]