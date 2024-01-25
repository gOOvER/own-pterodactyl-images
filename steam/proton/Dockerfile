# ---------------------------------------------
# Steam Proton image
# ---------------------------------------------
FROM        debian:bookworm-slim

LABEL       author="Torsten Widmann" maintainer="info@goover.de"
LABEL       org.opencontainers.image.source="https://github.com/gOOvER/own-pterodactyl-images"
LABEL       org.opencontainers.image.licenses=MIT

ARG         DEBIAN_FRONTEND=noninteractive
COPY        sources.list /etc/apt/sources.list
RUN         dpkg --add-architecture i386
RUN         apt update \ 
            && apt -y upgrade

RUN         apt install -y --no-install-recommends  \
                alsa-tools \
                ca-certificates \
                cabextract \
                curl \
                dbus \
                dirmngr \
                ffmpeg \
                g++ \
                gcc \
                gcc-12-base \
                gdb \
                gettext \
                git \
                gnupg \
                gnupg2 \
                gnutls-bin \
                iproute2 \
                jq \
                locales \
                mesa-utils \
                net-tools \
                netcat-openbsd \
                numactl \
                pipx \
                psmisc \
                pulseaudio \
                python3 \
                python3-dev \
                python3-pip \
                python3-setuptools \
                python3-venv \
                sed \
                software-properties-common \
                speex:i386 \
                tar \
                telnet \
                tini \
                tzdata \
                virt-what \
                wget \
                winbind \
                xauth \
                xvfb \
                lib32gcc-s1 \
                lib32stdc++6 \
                lib32tinfo6 \
                lib32z1 \
                libao-common \
                libasound2 \
                libatk1.0-0 \
                libatomic1 \
                libc++-dev \
                libc++1 \
                libc6 \
                libc6:i386 \
                libcurl3-gnutls \
                libcurl3-gnutls:i386 \
                libcurl4 \
                libcurl4-gnutls-dev \
                libcurl4-gnutls-dev:i386 \
                libcurl4:i386 \
                libfontconfig \
                libgcc-s1 \
                libgcc1 \
                libgconf-2-4 \
                libgdiplus \
                libgtk2.0-0:i386 \
                libjemalloc2 \
                libjemalloc2:i386 \
                libncurses5-dev:i386 \
                libncurses6 \
                libnss-wrapper \
                libnss3 \
                libntlm0 \
                libpangocairo-1.0-0 \
                libpulse-dev \
                libpulse0 \
                libsdl1.2-compat \
                libsdl1.2-compat:i386 \
                libsdl1.2debian \
                libsdl1.2debian:i386 \
                libsdl2-2.0-0 \
                libsdl2-2.0-0:i386 \
                libssl3 \
                libssl3:i386 \
                libstdc++6 \
                libstdc++6:i386 \
                libtcmalloc-minimal4 \
                libtcmalloc-minimal4:i386 \
                libtinfo6:i386 \
                libxcomposite1 \
                libxcursor1 \
                libxdamage1 \
                libxi6 \
                libxrandr2 \
                libxss1 \
                libxtst6

# Download Proton GE
RUN         curl -sLOJ $(curl -s https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/latest | grep browser_download_url | cut -d\" -f4 | egrep .tar.gz)
RUN         tar -xzf GE-Proton*.tar.gz -C /usr/local/bin/ --strip-components=1
RUN         rm GE-Proton*.*

# Proton Fix machine-id
RUN         rm -f /etc/machine-id
RUN         dbus-uuidgen --ensure=/etc/machine-id
RUN         rm /var/lib/dbus/machine-id
RUN         dbus-uuidgen --ensure

RUN         echo "* hard nice -20" | tee -a /etc/security/limits.conf

# Set up Winetricks
RUN	    wget -q -O /usr/sbin/winetricks https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks \
            && chmod +x /usr/sbin/winetricks

# Install Protontricks
RUN     pipx install protontricks

# Set the locale
RUN         sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
            locale-gen
ENV         LANG en_US.UTF-8  
ENV         LANGUAGE en_US:en  
ENV         LC_ALL en_US.UTF-8

## install rcon
RUN         cd /tmp/ \
            && curl -sSL https://github.com/gorcon/rcon-cli/releases/download/v0.10.3/rcon-0.10.3-amd64_linux.tar.gz > rcon.tar.gz \
            && tar xvf rcon.tar.gz \
            && mv rcon-0.10.3-amd64_linux/rcon /usr/local/bin/

## Prepare NSS Wrapper for the entrypoint as a workaround for games requiring a valid UID
ENV         NSS_WRAPPER_PASSWD=/tmp/passwd NSS_WRAPPER_GROUP=/tmp/group
RUN         touch ${NSS_WRAPPER_PASSWD} ${NSS_WRAPPER_GROUP} \
            && chgrp 0 ${NSS_WRAPPER_PASSWD} ${NSS_WRAPPER_GROUP} \
            && chmod g+rw ${NSS_WRAPPER_PASSWD} ${NSS_WRAPPER_GROUP}
ADD         passwd.template /passwd.template

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