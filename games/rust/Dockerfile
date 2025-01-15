FROM 		node:22-slim

ARG         DEBIAN_FRONTEND=noninteractive

RUN			dpkg --add-architecture i386 \
			&& apt update \
			&& apt upgrade -y

RUN			apt install -y \
				lib32gcc-s1 \
				lib32stdc++6 \
				locales \
				unzip \
				curl \
				iproute2 \
				tzdata \
				libgdiplus \
				libsdl2-2.0-0:i386

RUN			mkdir /wrapper \
			&& npm install --prefix /wrapper ws

# Set the locale
RUN        	sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
           	locale-gen
ENV      	LANG=en_US.UTF-8
ENV       	LANGUAGE=en_US:en
ENV        	LC_ALL=en_US.UTF-8

## Setup user and working directory
RUN         useradd -m -d /home/container -s /bin/bash container
USER        container
ENV         USER=container HOME=/home/container

WORKDIR 	/home/container

COPY 		./entrypoint.sh /entrypoint.sh
COPY 		./wrapper.js /wrapper/wrapper.js
RUN			chmod +x /wrapper/wrapper.js

CMD			[ "/bin/bash", "/entrypoint.sh" ]
