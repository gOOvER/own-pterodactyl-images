FROM        shipilev/openjdk:17

LABEL       author="Michael Parker" maintainer="parker@pterodactyl.io"

RUN 		    apt update -y \
 			      && apt install -y curl ca-certificates openssl git tar sqlite3 fontconfig tzdata iproute2 libfreetype6 font-manager ipset \
 			      && useradd -d /home/container -m container

USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

COPY        ./../entrypoint.sh /entrypoint.sh
CMD         [ "/bin/bash", "/entrypoint.sh" ]
