# ---------------------------------------------
# Steam Proton-GE image
# ---------------------------------------------
FROM debian:trixie-slim

# Metadata
LABEL org.opencontainers.image.description="STEAM Proton-GE Image to use with Pelican/Pterodactyl Gamepanel"
LABEL org.opencontainers.image.authors="info@goover.de"
LABEL org.opencontainers.image.source="https://github.com/gOOvER/own-pterodactyl-images"
LABEL org.opencontainers.image.licenses=AGPL-3.0-or-later

# Use bash as default shell
SHELL ["/bin/bash", "-c"]

# Set noninteractive frontend for apt
ARG DEBIAN_FRONTEND=noninteractive

# Enable 32-bit architecture and update system
RUN dpkg --add-architecture i386 && \
    apt update && apt -y upgrade

# Install required packages (merge into one layer)
RUN apt install -y --no-install-recommends \
    alsa-tools \
    ca-certificates \
    cabextract \
    curl \
    dbus \
    ffmpeg \
    file \
    flatpak \
    git \
    gnupg \
    gnupg2 \
    gnutls-bin \
    iproute2 \
    locales \
    numactl \
    mesa-utils \
    net-tools \
    netcat-openbsd \
    openssl \
    pulseaudio \
    python3 \
    python3-pip \
    python3-setuptools \
    python3-venv \
    pipx \
    tar \
    tini \
    virt-what \
    wget \
    winbind \
    xauth \
    xvfb \
    yad \
    lib32gcc-s1 \
    libao-common \
    libasound2 \
    libfreetype6 \
    libfreetype6:i386 \
    libsdl1.2debian \
    libsdl1.2debian:i386 \
    libsdl2-2.0-0 \
    libsdl2-2.0-0:i386 \
    libssl3 \
    libssl3:i386 \
    libgdiplus \
    libncurses5-dev:i386 \
    libncurses6 \
    libntlm0 \
    libnss-wrapper \
    libnss3 \
    libpulse-dev \
    libpulse0 \
    libgstreamer1.0-dev \
    libgstreamer-plugins-base1.0-dev \
    libgstreamer-plugins-bad1.0-dev \
    gstreamer1.0-plugins-base \
    gstreamer1.0-plugins-good \
    gstreamer1.0-plugins-bad \
    gstreamer1.0-plugins-ugly \
    gstreamer1.0-libav \
    gstreamer1.0-tools \
    gstreamer1.0-x \
    gstreamer1.0-alsa \
    gstreamer1.0-gl \
    gstreamer1.0-pulseaudio && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

# Download and install Proton-GE latest release
RUN cd /tmp && \
    PROTON_URL=$(curl -s https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/latest \
    | grep browser_download_url | cut -d\" -f4 | egrep .tar.gz) && \
    curl -sLOJ $PROTON_URL && \
    tar -xzf GE-Proton*.tar.gz -C /usr/local/bin/ --strip-components=1 && \
    rm GE-Proton*.*

# Proton machine-id fix
RUN rm -f /etc/machine-id /var/lib/dbus/machine-id && \
    dbus-uuidgen --ensure=/etc/machine-id && \
    dbus-uuidgen --ensure

# Install Winetricks and bash completion
RUN wget -q -O /usr/sbin/winetricks https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks && \
    chmod +x /usr/sbin/winetricks && \
    wget -q -O /usr/share/bash-completion/completions/winetricks \
    https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks.bash-completion

# Set locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# -----------------------------
# RCON CLI installation (latest release)
# -----------------------------
RUN cd /tmp \
    && RCON_LATEST=$(curl -s https://api.github.com/repos/gorcon/rcon-cli/releases/latest \
        | grep browser_download_url | cut -d\" -f4 | grep amd64_linux) \
    && curl -sSL $RCON_LATEST -o rcon.tar.gz \
    && tar xvf rcon.tar.gz \
    && mv rcon-*-amd64_linux/rcon /usr/local/bin/ \
    && chmod +x /usr/local/bin/rcon \
    && rm -rf /tmp/*

# Create non-root user and set working directory
RUN useradd -m -d /home/container -s /bin/bash container
USER container
ENV USER=container HOME=/home/container
WORKDIR /home/container

# Default stop signal
STOPSIGNAL SIGINT

# Copy entrypoint (adjust path if needed)
ARG ENTRYPOINT_PATH=../entrypoint.sh
COPY --chown=container:container ${ENTRYPOINT_PATH} /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Use tini init and entrypoint script
ENTRYPOINT ["/usr/bin/tini", "-g", "--"]
CMD ["/entrypoint.sh"]
