# ---------------------------------------------
# Steam Proton image
# ---------------------------------------------
FROM        debian:bookworm-slim

LABEL       author="Torsten Widmann" maintainer="info@goover.de"

RUN         dpkg --add-architecture i386
RUN         apt update \
            && apt install -y software-properties-common \
            && apt-add-repository --component non-free \
            && apt-add-repository --component contrib \
            && apt update \
            && apt -y upgrade
            
RUN         apt install -y \
					curl \
                    alsa-tools \
                    cabextract \
                    dbus \
                    gnupg \
                    gnupg2 \
                    gnutls-bin \
                    iproute2 \
					locales \
                    netcat-openbsd \
                    numactl \
                    pulseaudio \
                    python3 \
                    python3-pip \
                    python3-setuptools \
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
                    libcurl3-gnutls:i386 \
                    libcurl4-gnutls-dev:i386 \
                    libfreetype6 \
                    libfreetype6:i386 \
                    libgcc1 \
                    libgdiplus \
                    libncurses5-dev:i386 \
                    libncurses5:i386 \
                    libncurses6 \
                    libntlm0 \
                    libpulse-dev \
                    libpulse0 \
                    libsdl2-2.0-0:i386 \
                    libssl3:i386 libcurl4:i386 \
                    libtinfo6:i386 

RUN         echo steam steam/question select "I AGREE" | debconf-set-selections
RUN         apt install -y steam
RUN         useradd -d /home/container -m container

# Download Proton GE
RUN         curl -sLOJ $(curl -s https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/latest | grep browser_download_url | cut -d\" -f4 | egrep .tar.gz)
RUN         tar -xzf GE-Proton*.tar.gz -C /usr/local/bin/ --strip-components=1
RUN         rm GE-Proton*.*

# Proton Fix machine-id
RUN         rm -f /etc/machine-id
RUN         dbus-uuidgen --ensure=/etc/machine-id
RUN         rm /var/lib/dbus/machine-id
RUN         dbus-uuidgen --ensure

#Setup Protontricks install
RUN         python3 -m pip install protontricks

# Set up Winetricks
RUN	        wget -q -O /usr/sbin/winetricks https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks \
            && chmod +x /usr/sbin/winetricks

## install rcon
RUN         cd /tmp/ \
            && curl -sSL https://github.com/gorcon/rcon-cli/releases/download/v0.10.3/rcon-0.10.3-amd64_linux.tar.gz > rcon.tar.gz \
            && tar xvf rcon.tar.gz \
            && mv rcon-0.10.3-amd64_linux/rcon /usr/local/bin/

USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

COPY        ./../entrypoint.sh /entrypoint.sh
CMD         [ "/bin/bash", "/entrypoint.sh" ]