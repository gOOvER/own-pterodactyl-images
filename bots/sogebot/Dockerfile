#
# sogeBot Install Image
#

FROM        --platform=$BUILDPLATFORM node:16-bullseye-slim

LABEL       author="Torsten Widmann" maintainer="info@goover.de"

LABEL       org.opencontainers.image.source="https://github.com/PteroForge/pterodactyl-images"
LABEL       org.opencontainers.image.licenses=MIT

ENV         DEBIAN_FRONTEND=noninteractive

RUN         dpkg --add-architecture i386 \
						&& apt update \
						&& apt upgrade -y \
						&& apt -y --no-install-recommends install ca-certificates curl lib32gcc-s1 libsdl2-2.0-0:i386 git wget unzip tar sqlite3 jq python3 build-essential
RUN 		npm install -g npm@latest