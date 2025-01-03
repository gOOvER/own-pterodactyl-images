FROM        --platform=$TARGETOS/$TARGETARCH mongo:7-jammy

LABEL       org.opencontainers.image.authors="info@goover.de"
LABEL       org.opencontainers.image.source="https://github.com/gOOvER/own-pterodactyl-images"
LABEL       org.opencontainers.image.licenses=AGPL-3.0-or-later
LABEL       org.opencontainers.image.description "Docker image for Pelican Hosting Panel and Pterodactyl"

# Update the repository and install needed packages
ARG         DEBIAN_FRONTEND=noninteractive
RUN         apt update \ 
            && apt -y upgrade
RUN         apt -y install --no-install-recommends \
                  autoconf \
                  automake \
                  build-essential \
                  ca-certificates \
                  curl \
                  dnsutils \
                  ffmpeg \
                  g++ \
                  git \
                  gnupg \
                  gnupg2 \
                  iproute2 \
                  iputils-ping \
                  locales \
                  netcat \
                  python3 \
                  python3-dev \
                  software-properties-common \
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
                  libtool

## install nodejs & yarn
RUN         mkdir -p /etc/apt/keyrings \
                && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
                && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list \
                && curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
                && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

RUN         apt update \
                && apt install -y nodejs yarn

# updating npm 
RUN         npm install npm@latest -g
RUN         npm install json5 tsc typescript ts-node @types/node --location=global

# install pnpm
RUN         corepack enable
RUN         corepack prepare pnpm@latest --activate

# Set the locale
RUN         	sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
            	locale-gen
ENV        		LANG=en_US.UTF-8
ENV         	LANGUAGE=en_US:en
ENV         	LC_ALL=en_US.UTF-8

## Setup user and working directory
RUN         useradd -m -d /home/container -s /bin/bash container
USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

# Sets the default stop signal as wings can (currently) only send a kill or generic stop
STOPSIGNAL SIGINT

COPY        --chown=container:container ../entrypoint.sh /entrypoint.sh
RUN         chmod +x /entrypoint.sh
ENTRYPOINT  ["/usr/bin/tini", "-g", "--"]
CMD         ["/entrypoint.sh"]