FROM    debian:bullseye-slim

LABEL   author="Torsten Widmann" maintainer="info@goover.de"

ENV     DEBIAN_FRONTEND noninteractive

RUN     apt update -y \
          && apt upgrade -y \
          && apt install -y apt-transport-https wget iproute2 \
          && wget https://packages.microsoft.com/config/debian/11/packages-microsoft-prod.deb -O packages-microsoft-prod.deb \
          && dpkg -i packages-microsoft-prod.deb \
          && rm packages-microsoft-prod.deb \
          && apt update -y \
          && apt install -y aspnetcore-runtime-2.1 libgdiplus

RUN     useradd -g 1000 -m -d /home/container container

USER    container
ENV     USER=container HOME=/home/container
WORKDIR /home/container

COPY    ./../entrypoint.sh /entrypoint.sh
CMD     ["/bin/bash", "/entrypoint.sh"]
