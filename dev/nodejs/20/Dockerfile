FROM        --platform=$TARGETOS/$TARGETARCH node:20-bookworm-slim

LABEL           author="Torsten Widmann" maintainer="info@goover.de"
LABEL           org.opencontainers.image.source="https://github.com/gOOvER/own-pterodactyl-images"
LABEL           org.opencontainers.image.licenses=MIT

ENV         DEBIAN_FRONTEND=noninteractive

RUN         apt update \
             && apt -y upgrade

RUN         apt -y install \
                autoconf \
                automake \
                build-essential \
                ca-certificates\
                curl \
                dnsutils \
				ffmpeg \
                g++ \
                git \
                gpg \
                gnupg2 \
                iproute2 \
                iputils-ping \
                libtool \
                python3 \
                python3-dev \
                sqlite3 \
                tzdata \
                zip \
				libnss3 \
                libsqlite3-dev

# updating npm 
RUN         npm install npm@latest -g

# add cloudflare repo
RUN         mkdir -p --mode=0755 /usr/share/keyrings \
                && curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null \
                && echo 'deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared bookworm main' | tee /etc/apt/sources.list.d/cloudflared.list \
                && apt update \ 
                && apt install -y cloudflared

RUN         setcap 'cap_net_raw+ep' "$(which ping)"

## Setup user and working directory
RUN         useradd -m -d /home/container -s /bin/bash container
USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

COPY        ./../entrypoint.sh /entrypoint.sh
CMD         ["/bin/bash", "/entrypoint.sh"]
