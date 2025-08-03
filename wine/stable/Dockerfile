FROM debian:bookworm-slim

LABEL org.opencontainers.image.authors="Torsten Widmann - gOOvER - info@goover.de"
LABEL org.opencontainers.image.source="https://github.com/gOOvER/own-pterodactyl-images"
LABEL org.opencontainers.image.description="Docker image for Pelican, Jexactyl & Pterodactyl"
LABEL org.opencontainers.image.licenses=AGPL-3.0-or-later

ARG DEBIAN_FRONTEND=noninteractive

# Install all dependencies
RUN dpkg --add-architecture i386 && \
    apt update && \
    apt -y upgrade && \
    apt install -y --no-install-recommends \
        apt-transport-https \
        binutils \
        ca-certificates \
        cabextract \
        curl \
        dos2unix \
        file \
        ffmpeg \
        g++ \
        gcc \
        gcc-11-base \
        gdb \
        git \
        gnupg2 \
        gnutls-bin \
        icu-devtools \
        iproute2 \
        locales \
        net-tools \
        netcat-openbsd \
        numactl \
        procps \
        python3 \
        rapidjson-dev \
        software-properties-common \
        sqlite3 \
        tar \
        telnet \
        tini \
        tzdata \
        unzip \
        wget \
        winbind \
        xauth \
        xvfb \
        xz-utils \
        zip \
        libatomic1 \
        libc++-dev \
        libc6 \
        libduktape207 \
        libevent-dev \
        libfluidsynth3 \
        libfontconfig \
        libgcc1 \
        libicu72 \
        liblua5.4-0 \
        liblzo2-2 \
        libmariadbclient-dev-compat \
        libncurses6:i386 \
        libntlm0 \
        libprotobuf32 \
        libsdl1.2debian \
        libsdl2-2.0-0 \
        libsdl2-2.0-0:i386 \
        libsqlite3-dev \
        libstdc++6 \
        libunwind8 \
        libz-dev \
        libzip4 && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

# Install Wine (choose branch via WINE_BRANCH env) and Winetricks
ENV WINE_BRANCH=stable
RUN mkdir -pm755 /etc/apt/keyrings && \
    wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key && \
    wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/debian/dists/bookworm/winehq-bookworm.sources && \
    apt update && \
    apt install -y --no-install-recommends winehq-${WINE_BRANCH} cabextract && \
    apt clean && \
    rm -rf /var/lib/apt/lists/* && \
    wget -q -O /usr/sbin/winetricks https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks && \
    chmod +x /usr/sbin/winetricks

# Install rcon-cli (separate step)
RUN cd /tmp/ && \
    curl -sSL https://github.com/gorcon/rcon-cli/releases/download/v0.10.3/rcon-0.10.3-amd64_linux.tar.gz | tar xz && \
    mv rcon-0.10.3-amd64_linux/rcon /usr/local/bin/ && \
    rm -rf /tmp/rcon*

# Set environment variables for Wine, locale, and Xvfb
ENV HOME=/home/container \
    WINEPREFIX=/home/container/.wine \
    WINEARCH=win64 \
    WINEDLLOVERRIDES="mscoree,mshtml=" \
    DISPLAY=:0 \
    DISPLAY_WIDTH=1024 \
    DISPLAY_HEIGHT=768 \
    DISPLAY_DEPTH=16 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

# Generate locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen

# Increase vm.max_map_count for Conan Exiles
RUN echo "vm.max_map_count = 16777216" > /etc/sysctl.d/20-max_map_count.conf

# Create user and set working directory
RUN useradd -m -d /home/container -s /bin/bash container && \
    mkdir -p /home/container && \
    chown container:container /home/container

STOPSIGNAL SIGINT

# Copy entrypoint script and set permissions (as root)
COPY --chown=container:container ./entrypoint.sh /entrypoint.sh
RUN dos2unix /entrypoint.sh && chmod +x /entrypoint.sh

USER container
WORKDIR /home/container

ENTRYPOINT ["/usr/bin/tini", "-g", "--"]
CMD ["/entrypoint.sh"]
