FROM        --platform=$BUILDPLATFORM debian:bullseye-slim

LABEL       author="Torsten Widmann" maintainer="info@goover.de"

ENV         DEBIAN_FRONTEND=noninteractive

RUN         dpkg --add-architecture i386
RUN         apt update
RUN         apt upgrade -y
RUN         apt install -y \
                wget \
                mesa-utils \
                git \
                tar \
                curl \
                gcc \
                g++ \
                iproute2 \
                gdb \
                sed \
                xvfb \
                python3 \
                python3-dev \
                python3-pip \
                jq \
                telnet \
                net-tools \
                netcat-openbsd \
                tzdata \
                psmisc \
                sqlite3 \
                libsdl1.2debian \
                libfontconfig1 \
                lib32gcc-s1 \
                libgcc1 \
                lib32tinfo6 \
                lib32z1 \
                lib32stdc++6 \
                libstdc++6 \
                libgdiplus \
                libcurl4 \
                libfontconfig1 \
                libpangocairo-1.0-0 \
                libnss3 \
                libgconf-2-4 \
                libxi6 \
                libxcursor1 \
                libxss1 \
                libxcomposite1 \
                libasound2 \
                libxdamage1 \
                libxtst6 \
                libatk1.0-0 \
                libxrandr2 \
                libcurl4 \
                libcurl4:i386 \
                libcurl4-gnutls-dev:i386 \
                libpulse-dev \
                libssl3 \
                libssl3:i386 \
                libtinfo6:i386 \
                libncurses5:i386 \
                libcurl3-gnutls:i386 \
                libsdl2-2.0-0 \
                libsdl2-2.0-0:i386 \
                libstdc++6:i386 \
                libc6:i386 \
                libtcmalloc-minimal4 \
                libswt-gtk-4-java

RUN         useradd -d /home/container -m container

RUN         apt install apt-transport-https ca-certificates wget dirmngr gnupg software-properties-common -y
RUN         wget -qO - https://adoptopenjdk.jfrog.io/adoptopenjdk/api/gpg/key/public | apt-key add -
RUN         add-apt-repository --yes https://adoptopenjdk.jfrog.io/adoptopenjdk/deb/
RUN         apt update
RUN         apt install adoptopenjdk-8-hotspot -y

USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

COPY        ./entrypoint.sh /entrypoint.sh
CMD         [ "/bin/bash", "/entrypoint.sh" ]
