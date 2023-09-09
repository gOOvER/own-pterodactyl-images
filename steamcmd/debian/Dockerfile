FROM        --platform=$BUILDPLATFORM debian:bookworm-slim

LABEL       author="Torsten Widmann" maintainer="info@goover.de"
LABEL       org.opencontainers.image.source="https://github.com/gOOvER/own-pterodactyl-images"
LABEL       org.opencontainers.image.licenses=MIT

# Sets the default stop signal as wings can (currently) only send a kill or generic stop
STOPSIGNAL SIGINT

ENV         DEBIAN_FRONTEND=noninteractive

RUN         dpkg --add-architecture i386
RUN         apt update \ 
            && apt -y upgrade

RUN         apt install -y \
                    wget \
                    dirmngr \
                    ca-certificates \
                    gnupg \
                    mesa-utils \
                    git \
                    tar \
                    curl \
                    gcc \
                    g++ \
                    iproute2 \
                    gdb \
                    jq \
                    git \
                    telnet \
                    net-tools \
                    netcat-openbsd \
                    tzdata \
                    psmisc \
                    python3 \
                    python3-dev \
                    python3-pip \
                    sed \
                    speex:i386 \
                    libgtk2.0-0:i386 \
                    dbus \
                    tini \
                    libfontconfig1 \
                    lib32gcc-s1 \
                    libgcc1 \
                    lib32tinfo6 \
                    lib32z1 \
                    lib32stdc++6 \
                    libstdc++6 \
                    libstdc++6:i386 \
                    libgdiplus \
                    libcurl3-gnutls:i386 \
                    libcurl4 \
                    libcurl4:i386 \
                    libcurl4-gnutls-dev:i386 \
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
                    libpulse-dev \
                    libtinfo6:i386 \
                    libncurses5:i386 \
                    libssl3 \
                    libssl3:i386 \
                    libsdl1.2debian \
                    libsdl1.2debian:i386 \
                    libsdl2-2.0-0 \
                    libsdl2-2.0-0:i386 \
                    libc6:i386 \
                    libtcmalloc-minimal4 \
                    libc++1 \
                    libnss-wrapper \
                    libnss-wrapper:i386

## install dotnet to support STEAM dotnet games
RUN     apt update -y \
          && apt upgrade -y \
          && wget https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb -O packages-microsoft-prod.deb \
          && dpkg -i packages-microsoft-prod.deb \
          && rm packages-microsoft-prod.deb \
          && apt update -y \
          && apt install -y \
                    aspnetcore-runtime-7.0 \
                    dotnet-sdk-7.0 \
                    libgdiplus

## install mono to support STEAM dotnet games
RUN         gpg --homedir /tmp --no-default-keyring --keyring /usr/share/keyrings/mono-official-archive-keyring.gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
RUN         echo "deb [signed-by=/usr/share/keyrings/mono-official-archive-keyring.gpg] https://download.mono-project.com/repo/debian stable-buster main" | tee /etc/apt/sources.list.d/mono-official-stable.list
RUN         apt update
RUN         apt install mono-complete -y                    

## install rcon
RUN         cd /tmp/ \
            && curl -sSL https://github.com/gorcon/rcon-cli/releases/download/v0.10.3/rcon-0.10.3-amd64_linux.tar.gz > rcon.tar.gz \
            && tar xvf rcon.tar.gz \
            && mv rcon-0.10.3-amd64_linux/rcon /usr/local/bin/

## Prepare NSS Wrapper for the entrypoint as a workaround for Arma 3 requiring a valid UID
ENV         NSS_WRAPPER_PASSWD=/tmp/passwd NSS_WRAPPER_GROUP=/tmp/group
RUN         touch ${NSS_WRAPPER_PASSWD} ${NSS_WRAPPER_GROUP} \
            && chgrp 0 ${NSS_WRAPPER_PASSWD} ${NSS_WRAPPER_GROUP} \
            && chmod g+rw ${NSS_WRAPPER_PASSWD} ${NSS_WRAPPER_GROUP}
ADD         passwd.template /passwd.template

## Setup user and working directory
RUN         useradd -m -d /home/container -s /bin/bash container
USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

## Copy over and execute entrypoint.sh
COPY        --chown=container:container ./../entrypoint.sh /entrypoint.sh
RUN         chmod +x /entrypoint.sh
ENTRYPOINT	["/usr/bin/tini", "-g", "--"]
CMD 		["/entrypoint.sh"]