# ---------------------------------------------
# Steam Proton image
# ---------------------------------------------
FROM        debian:bookworm-slim

LABEL       author="Torsten Widmann" maintainer="info@goover.de"
LABEL       org.opencontainers.image.description "STEAM Proton-GE Image to use with Pterodactyl Gamepanel"
LABEL       org.opencontainers.image.source="https://github.com/gOOvER/own-pterodactyl-images"
LABEL       org.opencontainers.image.licenses=MIT

ARG         DEBIAN_FRONTEND=noninteractive
COPY        sources.list /etc/apt/sources.list
RUN         dpkg --add-architecture i386
RUN         apt update \ 
            && apt -y upgrade

RUN         apt install -y --no-install-recommends  \
                alsa-tools \
                cabextract \
                curl \
                dbus \
                ffmpeg \
                file \
                #flatpak \
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
                pulseaudio \
                python3 \
                python3-pip \
                python3-setuptools \
                python3-venv \
                pipx \
                software-properties-common \
                tar \
                tini \
                virt-what \
                wget \
                winbind \
                xauth \
                xvfb \
                yad \
                lib32gcc-s1 \
                libao-common \
                libasound2 \
                libfreetype6 \
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
                libpulse-dev \
                libpulse0 

# Download Proton GE
RUN         curl -sLOJ $(curl -s https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/latest | grep browser_download_url | cut -d\" -f4 | egrep .tar.gz)
RUN         tar -xzf GE-Proton*.tar.gz -C /usr/local/bin/ --strip-components=1
RUN         rm GE-Proton*.*

# Proton Fix machine-id
RUN         rm -f /etc/machine-id
RUN         dbus-uuidgen --ensure=/etc/machine-id
RUN         rm /var/lib/dbus/machine-id
RUN         dbus-uuidgen --ensure

# Set up Winetricks
RUN	        wget -q -O /usr/sbin/winetricks https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks \
                && chmod +x /usr/sbin/winetricks
RUN         wget -q -O /usr/share/bash-completion/completions/winetricks https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks.bash-completion

# add flatpak repo and Install Protontricks
#RUN         flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
#RUN         flatpak -y install flathub com.github.Matoking.protontricks
#RUN         echo "alias protontricks='flatpak run com.github.Matoking.protontricks'" >> ~/.bashrc
#RUN         echo "alias protontricks-launch='flatpak run --command=protontricks-launch com.github.Matoking.protontricks'" >> ~/.bashrc

# Install Protontricks 
RUN         pipx install protontricks
RUN         pipx ensurepath
# Debug
#RUN         find -name "protontricks"

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