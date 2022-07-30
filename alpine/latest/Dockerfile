FROM alpine:latest

# Install wine and wget
RUN apk update
RUN apk upgrade
RUN apk add --no-cache wine tzdata xvfb wget
RUN apk add winetricks --update-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing/ --allow-untrusted

RUN adduser -D -h /home/container container

# ENV
ENV HOME=/home/container
ENV WINEPREFIX=/home/container/.wine
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
CMD	["/bin/ash", "/entrypoint.sh"]
