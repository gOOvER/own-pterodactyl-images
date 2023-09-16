FROM        --platform=$TARGETOS/$TARGETARCH node:16-bookworm-slim

LABEL       author="Torsten Widmann" maintainer="info@goover.de"
LABEL       org.opencontainers.image.source="https://github.com/gOOvER/own-pterodactyl-images"
LABEL       org.opencontainers.image.licenses=MIT

RUN         apt update \
             && apt -y upgrade

RUN         apt -y install \
                autoconf \
                automake \
                build-essential \
                ca-certificates\
                dnsutils \
				ffmpeg \
                g++ \
                git \
                iproute2 \
                libtool \
                python3 \
                python3-dev \
                sqlite3 \
                tzdata \
                zip \
				libnss3 \
                libsqlite3-dev

# add cloudflare repo
RUN         mkdir -p --mode=0755 /usr/share/keyrings \
                && curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null \
                && echo 'deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared bookworm main' | tee /etc/apt/sources.list.d/cloudflared.list \
                && apt update \ 
                && apt install -y cloudflared

## Setup user and working directory
RUN             useradd -m -d /home/container -s /bin/bash container
USER            container
ENV             USER=container HOME=/home/container
WORKDIR         /home/container

COPY        ./../entrypoint.sh /entrypoint.sh
CMD         ["/bin/bash", "/entrypoint.sh"]
