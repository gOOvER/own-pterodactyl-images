FROM        --platform=$TARGETOS/$TARGETARCH eclipse-temurin:24-jdk-noble

LABEL       org.opencontainers.image.authors="info@goover.de"
LABEL       org.opencontainers.image.source="https://github.com/gOOvER/own-pterodactyl-images"
LABEL       org.opencontainers.image.licenses=AGPL-3.0-or-later
LABEL       org.opencontainers.image.description="Docker image for Pelican Hosting Panel and Pterodactyl"


RUN 		apt update -y \
			&& apt -y upgrade

RUN  		apt install -y \
				ca-certificates \
				curl \
				font-manager \
				fontconfig \
				git \
				iproute2 \
				ipset \
				locales \
				openssl \
				sqlite3 \
				tar \
				tzdata \
				libfreetype6

# Set the locale
RUN       	sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
           	locale-gen
ENV      	LANG=en_US.UTF-8
ENV        	LANGUAGE=en_US:en
ENV        	LC_ALL=en_US.UTF-8

## Setup user and working directory
RUN     	useradd -m -d /home/container -s /bin/bash container
USER    	container
ENV     	USER=container HOME=/home/container
WORKDIR 	/home/container

COPY        ./../entrypoint.sh /entrypoint.sh
CMD         [ "/bin/bash", "/entrypoint.sh" ]
