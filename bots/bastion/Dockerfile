FROM        --platform=$TARGETOS/$TARGETARCH node:18-bullseye

## install mongo
RUN         wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | apt-key add - \
                && echo "deb http://repo.mongodb.org/apt/debian bullseye/mongodb-org/6.0 main" | tee /etc/apt/sources.list.d/mongodb-org-6.0.list \
                && apt update \
                && apt install -y mongodb-org mongodb-org-server mongodb-org-shell mongodb-org-mongos mongodb-org-tools \
                ## install bastion reqs
                && apt install -y python3 build-essential git libtool netcat ffmpeg iproute2 curl \
                && npm install -g npm@latest \
                ## add container user
                && useradd -d /home/container -m container -s /bin/bash

USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

COPY        ./entrypoint.sh /entrypoint.sh
CMD         ["/bin/bash", "/entrypoint.sh"]