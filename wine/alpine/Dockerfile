FROM ghcr.io/parkervcp/yolks:alpine

# Install wine and wget
RUN apk update \
 && apk add --update --no-cache wine \
 && apk add --update --no-cache winetricks --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing/ \
 && apk add --update --no-cache wget

RUN adduser -D -h /home/container container

# ENV
ENV HOME=/home/container
ENV WINEPREFIX=/home/container/.mine
ENV WINEDLLOVERRIDES="mscoree,mshtml="
ENV DISPLAY=:0
ENV DISPLAY_WIDTH=1024
ENV DISPLAY_HEIGHT=768
ENV DISPLAY_DEPTH=16
ENV AUTO_UPDATE=1
ENV XVFB=1

# 
USER container
WORKDIR	/home/container

#
COPY ./entrypoint.sh /entrypoint.sh
CMD	["/bin/bash", "/entrypoint.sh"]
