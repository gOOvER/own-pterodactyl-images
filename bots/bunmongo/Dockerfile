FROM --platform=$TARGETOS/$TARGETARCH mongo:8-noble

LABEL org.opencontainers.image.authors="info@goover.de" \
      org.opencontainers.image.source="https://github.com/gOOvER/own-pterodactyl-images" \
      org.opencontainers.image.licenses=AGPL-3.0-or-later \
      org.opencontainers.image.description="Docker image for Pelican Hosting Panel and Pterodactyl"

ARG DEBIAN_FRONTEND=noninteractive

# Install dependencies, Node.js, Yarn & cleanup build deps
RUN apt-get update && apt-get -y upgrade && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        dnsutils \
        ffmpeg \
        git \
        gnupg \
        iproute2 \
        iputils-ping \
        locales \
        netcat-openbsd \
        python3 \
        python3-dev \
        sqlite3 \
        tini \
        tzdata \
        zip \
        libcairo2-dev \
        libgif-dev \
        libnss3 \
        libpango1.0-dev \
        librsvg2-dev \
        libsqlite3-dev \
    # temporäre Build-Tools für Node/Yarn
    && apt-get install -y --no-install-recommends \
        autoconf \
        automake \
        build-essential \
        g++ \
        libtool \
        software-properties-common \
    && mkdir -p /etc/apt/keyrings \
    # Install Bun (latest) globally using BUN_INSTALL to a shared location
    && export BUN_INSTALL=/usr/local/bun \
    && curl -fsSL https://bun.sh/install | bash \
    && ln -sf /usr/local/bun/bin/bun /usr/local/bin/bun \
    # NPM + PNPM
    && npm install -g npm@latest \
    && npm install -g json5 tsc typescript ts-node @types/node corepack@latest \
    && corepack enable pnpm \
    # Locale
    && sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen \
    # CleanUp: Build-Dependencies entfernen
    && apt-get purge -y --auto-remove \
        autoconf \
        automake \
        build-essential \
        g++ \
        libtool \
        software-properties-common \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

# Create user
RUN useradd -m -d /home/container -s /bin/bash container
USER container
ENV USER=container HOME=/home/container
WORKDIR /home/container

# Stop signal
STOPSIGNAL SIGINT

# Copy entrypoint
COPY --chown=container:container entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/usr/bin/tini", "-g", "--"]
CMD ["/entrypoint.sh"]
