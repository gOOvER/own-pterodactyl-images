FROM        --platform=$TARGETOS/$TARGETARCH node:18-bookworm-slim

LABEL       author="Torsten Widmann" maintainer="info@goover.de"
LABEL       org.opencontainers.image.source="https://github.com/gOOvER/own-pterodactyl-images"
LABEL       org.opencontainers.image.licenses=MIT

RUN         apt update \
            && apt -y upgrade \
            && apt -y install \
                  ffmpeg \
                  iproute2 \
                  git \
                  sqlite3 \
                  libsqlite3-dev \
                  python3 \
                  python3-dev \
                  ca-certificates \
                  dnsutils \
                  tzdata \
                  zip \
                  libnss3 \
                  autoconf \
                  automake \
                  g++ \
                  libtool \
                  build-essential \
                  iputils-ping \
                  curl

RUN         useradd -d /home/container -m container

# add cloudflare repo
RUN         mkdir -p /usr/share/keyrings \
                && curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null \
                && echo 'deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared bookworm main' | tee /etc/apt/sources.list.d/cloudflared.list \
                && apt update \ 
                && apt install -y cloudflared

RUN         npm install npm@latest -g

USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

COPY        ./../entrypoint.sh /entrypoint.sh
CMD         ["/bin/bash", "/entrypoint.sh"]
