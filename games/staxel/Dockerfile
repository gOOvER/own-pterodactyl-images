# ----------------------------------
# Mono Latest Image
# Minimum Panel Version: 1.2.x
# ----------------------------------
FROM        debian:bullseye-slim

LABEL       author="Torsten Widmann" maintainer="support@goover.de"

ENV         DEBIAN_FRONTEND=noninteractive

RUN         dpkg --add-architecture i386

RUN         apt update \
            && apt -y upgrade
RUN         apt install -y fontconfig dirmngr iproute2
RUN         apt install -y wget mesa-utils git tar curl gcc g++ iproute2 gdb libsdl1.2debian libfontconfig1 telnet net-tools netcat tzdata psmisc lib32gcc-s1 libgcc1 lib32tinfo6 lib32z1 lib32stdc++6 libstdc++6 libgdiplus
RUN         apt install -y libcurl4 libfontconfig1 libpangocairo-1.0-0 libnss3 libgconf-2-4 libxi6 libxcursor1 libxss1 libxcomposite1 libasound2 libxdamage1 libxtst6 libatk1.0-0 libxrandr2 libcurl4 libpulse-dev
RUN         apt install -y libcurl4-gnutls-dev:i386 libssl1.1:i386 libcurl4:i386 libtinfo6:i386 libncurses5:i386 libcurl3-gnutls:i386 libsdl2-2.0-0:i386 libstdc++6:i386 libc6:i386
RUN         apt install -y python3 python3-dev python3-pip jq git libtcmalloc-minimal4 sed
RUN         apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
RUN         sh -c 'echo "deb https://download.mono-project.com/repo/debian stable-buster main" > /etc/apt/sources.list.d/mono-official-stable.list'
RUN         apt update
RUN         apt install mono-complete mono-xsp4 mono-devel xvfb -y

RUN         useradd -d /home/container -m container

USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

COPY        ./entrypoint.sh /entrypoint.sh
CMD         ["/bin/bash", "/entrypoint.sh"]
