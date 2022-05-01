FROM  ubuntu:22.04

LABEL author="Torsten Widmann" maintainer="info@goover.de"

ENV   DEBIAN_FRONTEND noninteractive

## add container user
RUN   useradd -m -d /home/container -s /bin/bash container

## update base packages
RUN   apt update \
 &&   apt upgrade -y

## install dependencies
RUN   apt install -y gcc g++ libgcc1 lib32gcc-s1 libc++-dev gdb libc6 git wget curl tar zip unzip binutils xz-utils liblzo2-2 cabextract iproute2 net-tools netcat telnet libatomic1 libsdl1.2debian libsdl2-2.0-0 \
        libfontconfig icu-devtools libunwind8 libssl-dev sqlite3 libsqlite3-dev libmariadb-dev locales ffmpeg apt-transport-https init-system-helpers \
        libcurl3-gnutls liblua5.1-0 libluajit-5.1-2 libsqlite3-0 bzip2 zlib1g

## configure locale
RUN   update-locale lang=en_US.UTF-8 \
 &&   dpkg-reconfigure --frontend noninteractive locales

WORKDIR /home/container

COPY  ./entrypoint.sh /entrypoint.sh
CMD   ["/bin/bash", "/entrypoint.sh"]
