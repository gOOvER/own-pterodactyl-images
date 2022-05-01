FROM    node:16-bullseye

LABEL   author="Michael Parker" maintainer="parker@pterodactyl.io"
## install mongo
RUN     apt update
RUN     apt install -y wget sudo gnupg
RUN     wget -qO - https://www.mongodb.org/static/pgp/server-5.0.asc | sudo tee -a /etc/apt/trusted.gpg.d/server-5.0.asc
RUN     echo "deb http://repo.mongodb.org/apt/debian buster/mongodb-org/5.0 main" | sudo tee /etc/apt/sources.list.d/mongodb-org-5.0.list
RUN     apt update
RUN     apt install -y mongodb-org

## install youtube-dl
RUN     apt install -y python3.9 python build-essential netcat ffmpeg 
RUN     wget    https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -O /usr/local/bin/yt-dlp
RUN     chmod   a+rx /usr/local/bin/yt-dlp

RUN     useradd -d /home/container -m container -s /bin/bash

USER    container
ENV     USER=container HOME=/home/container
WORKDIR /home/container

COPY    ./entrypoint.sh /entrypoint.sh
CMD     ["/bin/bash", "/entrypoint.sh"]
