FROM        --platform=$TARGETOS/$TARGETARCH debian:bookworm-slim

LABEL       maintainer="info@goover.de>" version="1.0"

ENV         DEBIAN_FRONTEND noninteractive

# Install Dependencies
RUN         apt update \
                && apt upgrade -y \
                && apt install -y \
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

RUN         curl -L https://yt-dl.org/downloads/latest/youtube-dl -o /usr/local/bin/youtube-dl \
                && chmod a+rx /usr/local/bin/youtube-dl

# Set the locale
RUN         sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
            locale-gen
ENV         LANG en_US.UTF-8  
ENV         LANGUAGE en_US:en  
ENV         LC_ALL en_US.UTF-8

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

COPY        ./entrypoint.sh /entrypoint.sh
CMD         ["/bin/bash", "/entrypoint.sh"]
