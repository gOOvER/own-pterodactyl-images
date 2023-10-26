FROM            --platform=$TARGETOS/$TARGETARCH ubuntu:22.04

LABEL           author="Daniel Barton" maintainer="danny6167@gmail.com"

ENV             DEBIAN_FRONTEND noninteractive

#RUN             timedatectl set-timezone Etc/UTC

RUN             dpkg --add-architecture i386 \
                && apt update \
                && apt upgrade -y
RUN             apt install -y \
 			gcc \
        		curl \
                        g++ \
                        gdb \
                        gettext \
                        iproute2 \
                        locales \
                        net-tools \
                        tar \
                        tini \
                        tzdata \
                        lib32stdc++6 \
                        lib32tinfo6 \
                        lib32z1 \
                        libatomic1 \
                        libc++-dev \
                        libc6 \
                        libcurl3-gnutls \
                        libcurl3-gnutls:i386 \
                        libcurl4-gnutls-dev:i386 \
                        libcurl4:i386 \
                        libgcc1 \
                        libncurses5:i386 \
                        libfontconfig \
                        libnss-wrapper \
                        libpulse-dev \
                        libpulse0 \
                        libsdl1.2debian \
                        libsdl2-2.0-0 \
                        libsdl2-2.0-0:i386 \
                        libssl3:i386 \
                        libtinfo6:i386

## Prepare NSS Wrapper for the entrypoint as a workaround for Valheim requiring a valid UID
ENV         NSS_WRAPPER_PASSWD=/tmp/passwd NSS_WRAPPER_GROUP=/tmp/group
RUN         touch ${NSS_WRAPPER_PASSWD} ${NSS_WRAPPER_GROUP} \
            && chgrp 0 ${NSS_WRAPPER_PASSWD} ${NSS_WRAPPER_GROUP} \
            && chmod g+rw ${NSS_WRAPPER_PASSWD} ${NSS_WRAPPER_GROUP}
ADD         passwd.template /passwd.template

## Setup user and working directory
RUN         useradd -m -d /home/container -s /bin/bash container
USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

COPY  ./entrypoint.sh /entrypoint.sh
CMD   [ "/bin/bash", "/entrypoint.sh" ]