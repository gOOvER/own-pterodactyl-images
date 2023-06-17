FROM        --platform=$TARGETOS/$TARGETARCH debian:bookworm-slim

LABEL       author="Torsten Widmann" maintainer="support@goover.de"

RUN         useradd -d /home/container -m container

RUN 		apt update -y
RUN         apt -y upgrade
RUN         apt install -y curl ca-certificates openssl git tar sqlite3 fontconfig tzdata iproute2 libfreetype6 wget apt-transport-https gnupg2 apt-utils software-properties-common procps

RUN         wget -O- -q https://apt.corretto.aws/corretto.key | apt-key add -
RUN         add-apt-repository 'deb https://apt.corretto.aws stable main'
RUN         apt update
RUN         apt install -y java-1.8.0-amazon-corretto-jdk

USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

COPY        ./../entrypoint.sh /entrypoint.sh
CMD         [ "/bin/bash", "/entrypoint.sh" ]
