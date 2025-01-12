FROM        --platform=$TARGETOS/$TARGETARCH debian:bookworm-slim

LABEL       org.opencontainers.image.description "STEAM Proton-GE Image to use with Pelican/Pterodactyl Gamepanel"
LABEL       org.opencontainers.image.authors="info@goover.de"
LABEL       org.opencontainers.image.source="https://github.com/gOOvER/own-pterodactyl-images"
LABEL       org.opencontainers.image.licenses=AGPL-3.0-or-later

# setup apt and install needed packages
ARG         DEBIAN_FRONTEND=noninteractive
RUN         apt update \
            && apt -y upgrade

RUN			apt -y install \
                ca-certificates \
                less \
                locales \
                pulseaudio \
                python3 \
                sudo \
                x11vnc \
                x11-xkb-utils \
                xvfb \
                iproute2 \
                ffmpeg \
                curl \
			    libasound2 \
                libegl1-mesa \
                libglib2.0-0 \
                libnss3 \
                libpci3 \
                libpulse0 \
                libxcursor1 \
                libxslt1.1 \
                libx11-xcb1 \
                libxkbcommon0 \
                tini

RUN         curl -sSL https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp \
                && chmod a+rx /usr/local/bin/youtube-dl

# Set the locale
RUN         sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
            locale-gen
ENV         LANG=en_US.UTF-8
ENV         LANGUAGE=en_US:en
ENV         LC_ALL=en_US.UTF-8

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
