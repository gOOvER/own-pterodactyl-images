# Pterodactyl-Images (Yolks)
Docker Images for the Hosting Panel Pterodactyl

A curated collection of core images that can be used with Pterodactyl's Egg system. Each image is rebuilt
periodically to ensure dependencies are always up-to-date.

All of these images are available for `linux/amd64` and `linux/arm64` versions, unless otherwise specified, to use
these images on an arm system, no modification to them or the tag is needed, they should just work.


## Available Images

### [Distros](/distros)

* [alpine](/distros/alpine)
  * `ghcr.io/goover/alpine:latest`
  * `ghcr.io/goover/alpine:edge`
  * `ghcr.io/goover/alpine:3.13`
  * `ghcr.io/goover/alpine:3.14`
  * `ghcr.io/goover/alpine:3.15`
  * `ghcr.io/goover/alpine:3.16`
  * `ghcr.io/goover/alpine:3.17`
* [archlinux](/distros/archlinux)
  * `ghcr.io/goover/archlinux:latest`
* [debian](/distros/debian)
  * `ghcr.io/goover/debian:10-buster`
  * `ghcr.io/goover/debian:11-bookworm`
* [ubuntu](/oses/ubuntu)
  * `ghcr.io/goover/ubuntu:18-bionic`
  * `ghcr.io/goover/ubuntu:20-focal`
  * `ghcr.io/goover/ubuntu:22-jammy`

### [Bot](/bot)

* [`bastion`](/bot/bastion)
  * `ghcr.io/goover/bot:bastion`
* [`parkertron`](/bot/parkertron)
  * `ghcr.io/goover/bot:parkertron`
* [`redbot`](/bot/red)
  * `ghcr.io/goover/bot:red`
* [`sinusbot`](/bot/sinusbot)
  * `ghcr.io/goover/bot:sinusbot`

### [Box64](/box64)

* [`Box64`](/box64)
  * `ghcr.io/goover/box64:latest`

### [Cassandra](/database/cassandra)

* [`cassandra_java8_python27`](/database/cassandra/cassandra_java8_python2)
  * `ghcr.io/goover/cassandra:java8_python2`
* [`cassandra_java11_python3`](/database/cassandra/cassandra_java11_python3)
  * `ghcr.io/goover/cassandra:java11_python3`

### [Dart](/dart)

* [`dart stable`](/dev/dart/stable)
  * `ghcr.io/goover/dart:stable`
* [`dart stable-sdk`](/dev/dart/stable-sdk)
  * `ghcr.io/goover/dart:stable-sdk`

### [dotNet](/dev/dotnet)

* [`dotnet6.0`](/dev/dotnet/6)
  * `ghcr.io/goover/dotnet:6`
* [`dotnet6.0`](/dev/dotnet/6-sdk)
  * `ghcr.io/goover/dotnet:6-sdk`
* [`dotnet7.0`](/dev/dotnet/7)
  * `ghcr.io/goover/dotnet:7`
* [`dotnet6.0`](/dev/dotnet/7-sdk)
  * `ghcr.io/goover/dotnet:7-sdk`

### [Erlang](/dev/erlang)

* [`erlang22`](/dev/erlang/22)
  * `ghcr.io/goover/erlang:22`
* [`erlang23`](/dev/erlang/23)
  * `ghcr.io/goover/erlang:23`
* [`erlang24`](/dev/erlang/24)
  * `ghcr.io/goover/erlang:24`

### [Games](/games)

* [`altv`](/games/altv)
  * `ghcr.io/goover/games:altv`
* [`altv`](/games/conan)
  * `ghcr.io/goover/games:conan`
* [`dayz`](/games/dayz)
  * `ghcr.io/goover/games:dayz`
* [`altv`](/games/interstellarrift)
  * `ghcr.io/goover/games:interstellarrift`
* [`mohaa`](games/mohaa)
  * `ghcr.io/goover/games:mohaa`
* [`riskofrain2`](games/riskofrain2)
  * `ghcr.io/goover/games:riskofrain2`
* [`samp`](/games/samp)
  * `ghcr.io/goover/games:samp`
* [`screeps`](games/screeps)
  * `ghcr.io/goover/games:screeps`
* [`staxel`](games/staxel)
  * `ghcr.io/goover/games:staxel`
* [`valheim`](/games/valheim)
  * `ghcr.io/goover/games:valheim`
* [`wurm`](games/wurm)
  * `ghcr.io/goover/games:wurm`

### [Golang](/go)

* [`go1.14`](/go/1.14)
  * `ghcr.io/parkervcp/yolks:go_1.14`
* [`go1.15`](/go/1.15)
  * `ghcr.io/parkervcp/yolks:go_1.15`
* [`go1.16`](/go/1.16)
  * `ghcr.io/parkervcp/yolks:go_1.16`
* [`go1.17`](/go/1.17)
  * `ghcr.io/parkervcp/yolks:go_1.17`
* [`go1.18`](/go/1.18)
  * `ghcr.io/parkervcp/yolks:go_1.18`
* [`go1.19`](/go/1.19)
  * `ghcr.io/parkervcp/yolks:go_1.19`

### [Java](/java)

* [`java8`](/java/8)
  * `ghcr.io/parkervcp/yolks:java_8`
* [`java11`](/java/11)
  * `ghcr.io/parkervcp/yolks:java_11`
* [`java16`](/java/16)
  * `ghcr.io/parkervcp/yolks:java_16`
* [`java17`](/java/17)
  * `ghcr.io/parkervcp/yolks:java_17`
* [`java19`](/java/19)
  * `ghcr.io/parkervcp/yolks:java_19`

### [MariaDB](/mariadb)

  * [`MariaDB 10.3`](/mariadb/10.3)
    * `ghcr.io/parkervcp/yolks:mariadb_10.3`
  * [`MariaDB 10.4`](/mariadb/10.4)
    * `ghcr.io/parkervcp/yolks:mariadb_10.4`
  * [`MariaDB 10.5`](/mariadb/10.5)
    * `ghcr.io/parkervcp/yolks:mariadb_10.5`
  * [`MariaDB 10.6`](/mariadb/10.6)
    * `ghcr.io/parkervcp/yolks:mariadb_10.6`
  * [`MariaDB 10.7`](/mariadb/10.7)
    * `ghcr.io/parkervcp/yolks:mariadb_10.7`

### [MongoDB](/mongodb)

  * [`MongoDB 4`](/mongodb/4)
    * `ghcr.io/parkervcp/yolks:mongodb_4`
  * [`MongoDB 5`](/mongodb/5)
    * `ghcr.io/parkervcp/yolks:mongodb_5`
 * [`MongoDB 6`](/mongodb/6)
    * `ghcr.io/parkervcp/yolks:mongodb_6`    

### [Mono](/mono)

* [`mono_latest`](/mono/latest)
  * `ghcr.io/parkervcp/yolks:mono_latest`

### [Nodejs](/nodejs)

* [`node12`](/nodejs/12)
  * `ghcr.io/parkervcp/yolks:nodejs_12`
* [`node14`](/nodejs/14)
  * `ghcr.io/parkervcp/yolks:nodejs_14`
* [`node16`](/nodejs/16)
  * `ghcr.io/parkervcp/yolks:nodejs_16`
* [`node17`](/nodejs/17)
  * `ghcr.io/parkervcp/yolks:nodejs_17`
* [`node18`](/nodejs/18)
  * `ghcr.io/parkervcp/yolks:nodejs_18`

### [PostgreSQL](/postgres)

  * [`Postgres 9`](/postgres/9)
    * `ghcr.io/parkervcp/yolks:postgres_9`
  * [`Postgres 10`](/postgres/10)
    * `ghcr.io/parkervcp/yolks:postgres_10`
  * [`Postgres 11`](/postgres/11)
    * `ghcr.io/parkervcp/yolks:postgres_11`
  * [`Postgres 12`](/postgres/12)
    * `ghcr.io/parkervcp/yolks:postgres_12`
  * [`Postgres 13`](/postgres/13)
    * `ghcr.io/parkervcp/yolks:postgres_13`
  * [`Postgres 14`](/postgres/14)
    * `ghcr.io/parkervcp/yolks:postgres_14`  

### [Python](/python)

* [`python3.7`](/python/3.7)
  * `ghcr.io/parkervcp/yolks:python_3.7`
* [`python3.8`](/python/3.8)
  * `ghcr.io/parkervcp/yolks:python_3.8`
* [`python3.9`](/python/3.9)
  * `ghcr.io/parkervcp/yolks:python_3.9`
* [`python3.10`](/python/3.10)
  * `ghcr.io/parkervcp/yolks:python_3.10`
* [`python3.11`](/python/3.11)
  * `ghcr.io/parkervcp/yolks:python_3.11`

### [Redis](/redis)

  * [`Redis 5`](/redis/5)
    * `ghcr.io/parkervcp/yolks:redis_5`
  * [`Redis 6`](/redis/6)
    * `ghcr.io/parkervcp/yolks:redis_6`
  * [`Redis 7`](/redis/7)
    * `ghcr.io/parkervcp/yolks:redis_7`

### [Rust](/rust)

* ['rust1.31'](/rust/1.31)
  * `ghcr.io/parkervcp/yolks:rust_1.31`
* ['rust1.56'](/rust/1.56)
  * `ghcr.io/parkervcp/yolks:rust_1.56`
* ['rust1.60'](/rust/1.60)
  * `ghcr.io/parkervcp/yolks:rust_1.60`
* ['rust latest'](/rust/latest)
  * `ghcr.io/parkervcp/yolks:rust_latest`

### [SteamCMD](/steamcmd)

* [`SteamCMD Debian lastest`](/steamcmd/debian)
  * `ghcr.io/parkervcp/steamcmd:debian`
* [`SteamCMD Debian Dotnet`](/steamcmd/dotnet)
  * `ghcr.io/parkervcp/steamcmd:dotnet`
* [`SteamCMD Ubuntu latest LTS`](/steamcmd/ubuntu)
  * `ghcr.io/parkervcp/steamcmd:ubuntu`

### [Voice](/voice)

* [`Mumble`](/voice/mumble)
  * `ghcr.io/parkervcp/yolks:voice_mumble`
* [`TeaSpeak`](/voice/teaspeak)
  * `ghcr.io/parkervcp/yolks:voice_teaspeak`

### [Wine](/wine)

* [`Wine`](/wine)
  * `ghcr.io/parkervcp/yolks:wine_latest`
  * `ghcr.io/parkervcp/yolks:wine_staging`

### [Installation Images](/installers)

* [`alpine-install`](/installers/alpine)
  * `ghcr.io/parkervcp/installers:alpine`
* [`debian-install`](/installers/debian)
  * `ghcr.io/parkervcp/installers:debian`
* [`ubuntu-install`](/installers/ubuntu)
  * `ghcr.io/parkervcp/installers:ubuntu`
