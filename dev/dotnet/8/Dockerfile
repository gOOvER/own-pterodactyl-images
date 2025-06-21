FROM    	--platform=$TARGETOS/$TARGETARCH debian:bookworm-slim

LABEL       org.opencontainers.image.authors="info@goover.de"
LABEL       org.opencontainers.image.source="https://github.com/gOOvER/own-pterodactyl-images"
LABEL       org.opencontainers.image.licenses=AGPL-3.0-or-later
LABEL       org.opencontainers.image.description="Docker image for Pelican Hosting Panel and Pterodactyl"
ARG         DEBIAN_FRONTEND=noninteractive

RUN         apt update \
             && apt -y upgrade

RUN         apt install -y --no-install-recommends \
                apt-transport-https \
				acl \
				ca-certificates \
				curl \
				gnupg \
                iproute2 \
				libc6 \
                locales \
                sqlite3 \
                tini \
                wget \
				libgdiplus \
			&& rm -rf /var/lib/apt/lists/*

## install dotnet
RUN          wget https://dot.net/v1/dotnet-install.sh \
            	&& D_V="$(curl -sSL https://dotnet.microsoft.com/en-us/download/dotnet/8.0 | grep -i  '<h3 id="sdk-8.*">SDK 8.*.*</h3>'  | head -1 | awk -F\" '{print $3}' | awk '{print $2;}' | sed 's/<\/h3>//g')" \
            	&& chmod +x dotnet-install.sh \
				&& ./dotnet-install.sh -i /usr/share -v $D_V \
            	&& ln -s /usr/share/dotnet /usr/bin/dotnet

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
