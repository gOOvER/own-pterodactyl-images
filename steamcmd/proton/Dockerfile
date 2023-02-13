# ---------------------------------------------
# Generic Wine image with Steam support
# ---------------------------------------------
FROM    debian:bullseye-slim

LABEL   author="Torsten Widmann" maintainer="info@goover.de"

## install required packages
RUN     dpkg --add-architecture i386
RUN     apt update
RUN     apt install -y --no-install-recommends wget iproute2 gnupg2 software-properties-common libntlm0 winbind xvfb xauth python3 libncurses5-dev:i386 libncurses6 dbus libgdiplus lib32gcc-s1
RUN     apt install -y alsa-tools libpulse-dev libasound2 libao-common gnutls-bin gnupg locales numactl cabextract curl
RUN     useradd -d /home/container -m container

# Download Proton GE
RUN     mkdir -p /usr/local/bin/proton
RUN     curl -sLOJ $(curl -s https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/latest | grep browser_download_url | cut -d\" -f4 | egrep .tar.gz)
RUN     tar -xzf GE-Proton*.tar.gz -C /usr/local/bin/proton --strip-components=1
RUN     rm GE-Proton*.*

# Set up Winetricks
RUN	    wget -q -O /usr/sbin/winetricks https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks
RUN     chmod +x /usr/sbin/winetricks

# Proton Fix machine-id
RUN     rm -f /etc/machine-id
RUN     dbus-uuidgen --ensure=/etc/machine-id
RUN     rm /var/lib/dbus/machine-id
RUN     dbus-uuidgen --ensure

ENV     HOME=/home/container

USER    container
ENV     USER=container HOME=/home/container
WORKDIR /home/container

COPY    ./entrypoint.sh /entrypoint.sh
CMD	    ["/bin/bash", "/entrypoint.sh"]
