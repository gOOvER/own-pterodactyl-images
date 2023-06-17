FROM        --platform=$BUILDPLATFORM debian:bookworm-slim

LABEL       author="Torsten Widmann" maintainer="info@goover.de"

ENV         DEBIAN_FRONTEND=noninteractive

RUN         dpkg --add-architecture i386
RUN         apt update
RUN         apt upgrade -y
RUN         apt install -y wget mesa-utils git tar curl gcc g++ iproute2 gdb libsdl1.2debian libfontconfig1 telnet net-tools netcat-openbsd tzdata psmisc lib32gcc-s1 libgcc1 lib32tinfo6 lib32z1 lib32stdc++6 libstdc++6 libgdiplus
RUN         apt install -y libcurl4 libfontconfig1 libpangocairo-1.0-0 libnss3 libgconf-2-4 libxi6 libxcursor1 libxss1 libxcomposite1 libasound2 libxdamage1 libxtst6 libatk1.0-0 libxrandr2 libcurl4 libpulse-dev
RUN         apt install -y libcurl4-gnutls-dev:i386 libssl1.1:i386 libcurl4:i386 libtinfo6:i386 libncurses5:i386 libcurl3-gnutls:i386 libsdl2-2.0-0:i386 libstdc++6:i386 libc6:i386
RUN         apt install -y python3 python3-dev python3-pip jq git libtcmalloc-minimal4 sed speex:i386 libgtk2.0-0:i386 dbus libc++1-11

RUN         useradd -d /home/container -m container

## install dotnet to support STEAM dotnet games
RUN     apt update -y \
          && apt upgrade -y \
          && wget https://packages.microsoft.com/config/debian/11/packages-microsoft-prod.deb -O packages-microsoft-prod.deb \
          && dpkg -i packages-microsoft-prod.deb \
          && rm packages-microsoft-prod.deb \
          && apt update -y \
          && apt install -y aspnetcore-runtime-7.0 dotnet-sdk-7.0 libgdiplus

## install rcon
RUN         cd /tmp/ \
            && curl -sSL https://github.com/gorcon/rcon-cli/releases/download/v0.10.3/rcon-0.10.3-amd64_linux.tar.gz > rcon.tar.gz \
            && tar xvf rcon.tar.gz \
            && mv rcon-0.10.3-amd64_linux/rcon /usr/local/bin/

USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

COPY        ./../entrypoint.sh /entrypoint.sh
CMD         [ "/bin/bash", "/entrypoint.sh" ]
