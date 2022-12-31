FROM        --platform=$TARGETOS/$TARGETARCH node:19-bullseye-slim

RUN         apt update \
            && apt -y install ffmpeg iproute2 git sqlite3 libsqlite3-dev python3 python3-dev ca-certificates dnsutils tzdata zip libnss3 libtool autoconf automake g++ libtool build-essential \
            && useradd -d /home/container -m container

RUN         npm install npm@latest -g
RUN         npm install typescript -g

USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

RUN         tsc -v

COPY        ../entrypoint.sh /entrypoint.sh
CMD         ["/bin/bash", "/entrypoint.sh"]
