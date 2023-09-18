FROM        --platform=$TARGETOS/$TARGETARCH eclipse-temurin:16-jdk-jammy

LABEL   author="Torsten Widmann" maintainer="info@goover.de"
LABEL   org.opencontainers.image.source="https://github.com/gOOvER/own-pterodactyl-images"
LABEL   org.opencontainers.image.licenses=MIT

RUN 		    apt update -y \
				&& apt -y upgrade

RUN  			apt install -y \
					ca-certificates \
					curl \
					font-manager \
					fontconfig \
					git \
					iproute2 \
					ipset \
					openssl \
					sqlite3 \
					tar \
					tzdata \
					libfreetype6

## configure locale
RUN     update-locale lang=en_US.UTF-8 \
         && dpkg-reconfigure --frontend noninteractive locales

## Setup user and working directory
RUN     useradd -m -d /home/container -s /bin/bash container
USER    container
ENV     USER=container HOME=/home/container
WORKDIR /home/container

COPY        ./../entrypoint.sh /entrypoint.sh
CMD         [ "/bin/bash", "/entrypoint.sh" ]
