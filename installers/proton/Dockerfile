# ---------------------------------------------
# Steam Proton image
# ---------------------------------------------
FROM        ubuntu:24.04

LABEL       org.opencontainers.image.description="STEAM Proton-GE Image to use with Pelican/Pterodactyl Gamepanel"
LABEL       org.opencontainers.image.authors="info@goover.de"
LABEL       org.opencontainers.image.source="https://github.com/gOOvER/own-pterodactyl-images"
LABEL       org.opencontainers.image.licenses=AGPL-3.0-or-later

# Env Setup
SHELL       [ "/bin/bash", "-c" ]

# setup apt and install needed packages
ARG         DEBIAN_FRONTEND=noninteractive
RUN         dpkg --add-architecture i386
RUN         apt update \
            && apt -y upgrade

RUN         apt install -y --no-install-recommends  \
                alsa-tools \
				ca-certificates \
                cabextract \
                curl \
                dbus \
                ffmpeg \
                file \
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
				protontricks \
                pulseaudio \
                python3 \
                python3-pip \
                python3-setuptools \
                python3-venv \
                pipx \
                software-properties-common \
				steam \
                tar \
                tini \
				unzip \
                virt-what \
                wget \
                winbind \
                xauth \
                xvfb \
                lib32gcc-s1 \
                libao-common \
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
                gstreamer1.0-pulseaudio

# Download Proton GE
RUN         curl -sLOJ $(curl -s https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/latest | grep browser_download_url | cut -d\" -f4 | egrep .tar.gz)
RUN         tar -xzf GE-Proton*.tar.gz -C /usr/local/bin/ --strip-components=1
RUN         rm GE-Proton*.*

# Proton Fix machine-id
RUN         rm -f /etc/machine-id
RUN         dbus-uuidgen --ensure=/etc/machine-id
RUN         rm /var/lib/dbus/machine-id
RUN         dbus-uuidgen --ensure
