FROM        --platform=$TARGETOS/$TARGETARCH node:14-bullseye-slim

RUN         apt update \
            && apt -y upgrade \
            && apt -y install ffmpeg iproute2 git sqlite3 libsqlite3-dev python3 python3-dev ca-certificates dnsutils tzdata zip tar curl build-essential \
            && apt -y install gconf-service libasound2 libatk1.0-0 libc6 libcairo2 libcups2 libdbus-1-3 libexpat1 libfontconfig1 libgcc1 libgconf-2-4 \
            && apt -y install libgdk-pixbuf2.0-0 libglib2.0-0 libgtk-3-0 libnspr4 libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 \
            && apt -y install libxcomposite1 libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 ca-certificates \
            && apt -y install fonts-liberation libnss3 lsb-release xdg-utils wget libgbm1 autoconf automake g++ libtool build-essential
RUN         npm -g install npm@latest
RUN         useradd -d /home/container -m container

RUN         npm install npm@latest -g

RUN         echo 'kernel.unprivileged_userns_clone=1' > /etc/sysctl.d/userns.conf

USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

COPY        ./../entrypoint.sh /entrypoint.sh
CMD         [ "/bin/bash", "/entrypoint.sh" ]
