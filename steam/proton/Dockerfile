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

# Enable 32-bit architecture, update system, install packages and pipx/protontricks in one layer
RUN dpkg --add-architecture i386 && \
    apt-get update && apt-get -y upgrade && \
    apt-get install -y --no-install-recommends \
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
    python3-full \
    python3-pip \
    python3-setuptools \
    python3-venv \
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
    # Install pipx and protontricks into an isolated virtualenv to avoid
    # PEP 668 "system site packages" warnings when pip detects a distro-managed
    # Python. We install into /opt/pytools and expose the tool entrypoints via
    # symlinks into /usr/local/bin.
    python3 -m venv /opt/pytools && \
    /opt/pytools/bin/python -m pip install --no-cache-dir --upgrade pip setuptools wheel && \
    /opt/pytools/bin/python -m pip install --no-cache-dir pipx protontricks && \
    ln -s /opt/pytools/bin/pipx /usr/local/bin/pipx || true && \
    ln -s /opt/pytools/bin/protontricks /usr/local/bin/protontricks || true && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/*

# Download and install Proton-GE latest release into /opt and register with Steam
RUN set -eux; cd /tmp; \
    # Determine Proton-GE latest tarball URL. Use a robust extraction that does
    # not rely on cut with multi-character delimiter (which fails on some shells).
    PROTON_JSON=$(curl -sSf https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/latest || true); \
    PROTON_URL=""; \
    if command -v jq >/dev/null 2>&1; then \
        PROTON_URL=$(printf '%s' "$PROTON_JSON" | jq -r '.assets[].browser_download_url' 2>/dev/null | grep '\.tar\.gz$' | head -n1 || true); \
    else \
        # Fallback to grep + sed: find the first browser_download_url value
        PROTON_URL=$(printf '%s' "$PROTON_JSON" | grep 'browser_download_url' || true); \
        PROTON_URL=$(printf '%s' "$PROTON_URL" | sed -n 's/.*"browser_download_url": "\([^"]*\.tar\.gz\)".*/\1/p' | head -n1 || true); \
    fi; \
    if [ -z "$PROTON_URL" ]; then echo "Could not determine Proton-GE URL" >&2; echo "Response snippet:"; printf '%s\n' "${PROTON_JSON:0:400}" >&2; exit 1; fi; \
    curl -sSL "$PROTON_URL" -o proton-ge.tar.gz; \
    if [ ! -s proton-ge.tar.gz ]; then echo "Downloaded Proton-GE archive is empty" >&2; ls -l proton-ge.tar.gz || true; exit 1; fi; \
    mkdir -p /opt; tar -xzf proton-ge.tar.gz -C /opt; \
    # find extracted folder (GE-Proton*), normalize to /opt/ProtonGE
    PROTON_DIR=$(find /opt -maxdepth 1 -type d -name 'GE-Proton*' -print -quit || true); \
    if [ -n "$PROTON_DIR" ]; then mv "$PROTON_DIR" /opt/ProtonGE; fi; \
    # Register tool for Steam (compatibilitytools.d expects a folder)
    if [ -d /opt/ProtonGE ]; then \
        rm -rf /usr/local/share/steam/compatibilitytools.d/ProtonGE || true; \
        mkdir -p /usr/local/share/steam/compatibilitytools.d; \
        cp -a /opt/ProtonGE /usr/local/share/steam/compatibilitytools.d/ProtonGE; \
    fi; \
    rm -rf /tmp/*

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
RUN set -eux; cd /tmp; \
    RCON_LATEST=$(curl -sSf https://api.github.com/repos/gorcon/rcon-cli/releases/latest | grep "browser_download_url" | cut -d'\"' -f4 | grep amd64_linux | head -n1) || true; \
    if [ -n "$RCON_LATEST" ]; then curl -sSL "$RCON_LATEST" -o rcon.tar.gz; tar xvf rcon.tar.gz; mv rcon-*-amd64_linux/rcon /usr/local/bin/ || true; chmod +x /usr/local/bin/rcon || true; fi; \
    rm -rf /tmp/*

# Create non-root user and set working directory
RUN useradd -m -d /home/container -s /bin/bash container && mkdir -p /home/container && chown container:container /home/container
ENV USER=container HOME=/home/container
WORKDIR /home/container
USER container

# Provide a simple system-wide `proton` wrapper that launches the installed
# Proton-GE. This makes `proton` available for all users inside the container.
RUN set -eux; \
    printf '%s\n' '#!/bin/bash' \
        'if [ -d /opt/ProtonGE ]; then' \
        '    PROTON_DIR=/opt/ProtonGE' \
        'elif [ -d /usr/local/share/steam/compatibilitytools.d/ProtonGE ]; then' \
        '    PROTON_DIR=/usr/local/share/steam/compatibilitytools.d/ProtonGE' \
        'else' \
        '    echo "Proton-GE not found (expected in /opt/ProtonGE or /usr/local/share/steam/compatibilitytools.d/ProtonGE)" >&2' \
        '    exit 1' \
        'fi' \
        'exec """$PROTON_DIR/proton""" "$@"' \
    > /usr/local/bin/proton; \
    chmod +x /usr/local/bin/proton

# Default stop signal
STOPSIGNAL SIGINT

# Copy entrypoint (adjust path if needed)
ARG ENTRYPOINT_PATH=../entrypoint.sh
COPY --chown=container:container ${ENTRYPOINT_PATH} /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Use tini init and entrypoint script
ENTRYPOINT ["/usr/bin/tini", "-g", "--"]
CMD ["/entrypoint.sh"]
