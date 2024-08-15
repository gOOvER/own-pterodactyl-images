FROM        --platform=$BUILDPLATFORM debian:bookworm-slim

LABEL       author="Torsten Widmann" maintainer="info@goover.de"
LABEL       org.opencontainers.image.source="https://github.com/gOOvER/own-pterodactyl-images"
LABEL       org.opencontainers.image.licenses=AGPL
LABEL       org.opencontainers.image.description Dockerimage for Pelican Hosting Panel and Pterodactyl

ARG         DEBIAN_FRONTEND=noninteractive

RUN         dpkg --add-architecture i386
RUN         apt update \ 
            && apt -y upgrade

RUN         apt install -y \
                    ca-certificates \
                    curl \
                    dbus \
                    dirmngr \
                    g++ \
                    gcc \
                    gdb \
                    gpg \
                    gettext \
                    git \
                    gnupg \
                    iproute2 \
                    iproute2 \
                    jq \
                    locales \
                    mesa-utils \
                    net-tools \
                    netcat-openbsd \
                    numactl \
                    psmisc \
                    python3 \
                    python3-dev \
                    python3-pip \
                    sed \
                    speex:i386 \
                    tar \
                    telnet \
                    tini \
                    tzdata \
                    wget \
                    unzip \
                    libgcc-s1 \
                    lib32gcc-s1 \
                    lib32stdc++6 \
                    lib32tinfo6 \
                    lib32z1 \
                    libasound2 \
                    libatk1.0-0 \
                    libatomic1 \
                    libc++-dev \
                    libc++1 \
                    libc6 \
                    libc6:i386 \
                    libcurl3-gnutls \
                    libcurl3-gnutls:i386 \
                    libcurl4 \
                    libcurl4-gnutls-dev:i386 \
                    libcurl4:i386 \
                    libfontconfig \
                    libgcc1 \
                    libgconf-2-4 \
                    libgdiplus \
                    libgtk2.0-0:i386 \
                    libicu72 \
                    libpangocairo-1.0-0 \
                    libpulse-dev \
                    libpulse0 \
                    libsdl1.2debian \
                    libsdl1.2debian:i386 \
                    libsdl2-2.0-0 \
                    libsdl2-2.0-0:i386 \
                    libssl3 \
                    libssl3:i386 \
                    libstdc++6 \
                    libstdc++6:i386 \
                    libtcmalloc-minimal4 \
                    libtinfo6:i386 \
                    libxcomposite1 \
                    libxcursor1 \
                    libxdamage1 \
                    libxi6 \
                    libxrandr2 \
                    libxss1 \
                    libxtst6 \
                    zlib1g

## add dotnet repos
RUN         wget https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb -O packages-microsoft-prod.deb \
            && dpkg -i packages-microsoft-prod.deb \
            && rm packages-microsoft-prod.deb \
            && apt update -y \
            && apt install -y \
                    aspnetcore-runtime-8.0 \
                    libgdiplus \
                    dotnet-sdk-8.0

# Install DepotDownloader
RUN             curl -sLOJ $(curl -s https://api.github.com/repos/SteamRE/DepotDownloader/releases/latest | grep browser_download_url | cut -d\" -f4 | egrep linux-x64.zip)
RUN             unzip DepotDownloader-linux-x64.zip -d /usr/local/bin/
RUN             chmod +x /usr/local/bin/DepotDownloader

# Set the locale
RUN         sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
            locale-gen
ENV         LANG en_US.UTF-8  
ENV         LANGUAGE en_US:en  
ENV         LC_ALL en_US.UTF-8