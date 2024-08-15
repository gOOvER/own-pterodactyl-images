FROM        debian:bookworm-slim

LABEL       author="Torsten Widmann" maintainer="info@goover.de"
LABEL       org.opencontainers.image.source="https://github.com/gOOvER/own-pterodactyl-images"
LABEL       org.opencontainers.image.licenses=AGPL
LABEL       org.opencontainers.image.description Dockerimage for Pelican Hosting Panel and Pterodactyl
RUN         apt update \
            && apt -y upgrade

RUN         apt install -y \
                fontconfig \
                dirmngr

#install mono        
RUN         apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
RUN         sh -c 'echo "deb https://download.mono-project.com/repo/debian stable-buster main" > /etc/apt/sources.list.d/mono-official-stable.list'
RUN         apt update
RUN         apt install \
                mono-complete -y

## Setup user and working directory
RUN             useradd -m -d /home/container -s /bin/bash container
USER            container
ENV             USER=container HOME=/home/container
WORKDIR         /home/container

COPY        ./entrypoint.sh /entrypoint.sh
CMD         ["/bin/bash", "/entrypoint.sh"]
