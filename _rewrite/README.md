
All Images are based on Parkers Yolks. I added some more packages and more versions

# Yolks

A curated collection of core images that can be used with Pterodactyl's Egg system. Each image is rebuilt
periodically to ensure dependencies are always up-to-date.

Images are hosted on `ghcr.io` and exist under the `games`, `installers`, and `yolks` spaces. The following logic
is used when determining which space an image will live under:

* `games` — anything within the `games` folder in the repository. These are images built for running a specific game
or type of game.
* `installers` — anything living within the `installers` directory. These images are used by install scripts for different
Eggs within Pterodactyl, not for actually running a game server. These images are only designed to reduce installation time
and network usage by pre-installing common installation dependencies such as `curl` and `wget`.
* `yolks` — these are more generic images that allow different types of games or scripts to run. They're generally just
a specific version of software and allow different Eggs within Pterodactyl to switch out the underlying implementation. An
example of this would be something like Java or Python which are used for running bots, Minecraft servers, etc.

All of these images are available for `linux/amd64` and `linux/arm64` versions, unless otherwise specified, to use
these images on an arm system, no modification to them or the tag is needed, they should just work.


## Available Images
### [Linux Distros](/oses)
* [Alpine](/oses/alpine)
  * `ghcr.io/goover/yolks_os:alpine`
* [Debian 10 Buster](/oses/debian10)
  * `ghcr.io/goover/yolks_os:debian10`
* [Debian 11 Bullseye](/oses/debian11)
  * `ghcr.io/goover/yolks_os:debian11`  
* [Ubuntu 18.04](/oses/ubuntu1804)
  * `ghcr.io/goover/yolks_os:ubuntu1804`
* [Ubuntu 20.04](/oses/ubuntu2004)
  * `ghcr.io/goover/yolks_os:ubuntu2004`  
* [Ubuntu 22.04](/oses/ubuntu2204)
  * `ghcr.io/goover/yolks_os:ubuntu2204`
### [Cassandra](/cassandra)
  * [`cassandra_java8_python27`](/cassandra/cassandra_java8_python2)
    * `ghcr.io/goover/yolks:cassandra_java8_python2`
  * [`cassandra_java11_python3`](/cassandra/cassandra_java11_python3)
    * `ghcr.io/goover/yolks:cassandra_java11_python3`

### [Amazon Corretto](/coretto)
  * [`Corretto 8`](/corretto/8)
    * `ghcr.io/goover/yolks:corretto_8`
  * [`Corretto 11`](/corretto/11)
    * `ghcr.io/goover/yolks:corretto_11`
  * [`Corretto 16`](/corretto/16)
    * `ghcr.io/goover/yolks:corretto_16`
  * [`Corretto 17`](/corretto/17)
    * `ghcr.io/goover/yolks:corretto_17`  
  * [`Corretto 18`](/corretto/18)
    * `ghcr.io/goover/yolks:corretto_18`    

### [dotNet](/dotnet)
  * [`DotNet 2.1`](/dotnet/2.1)
    * `ghcr.io/goover/yolks:dotnet_2.1`
  * [`DotNet 2.1-sdk`](/dotnet/2.1-sdk)
    * `ghcr.io/goover/yolks:dotnet_2.1-sdk`
  * [`DotNet 3.1`](/dotnet/3.1)
    * `ghcr.io/goover/yolks:dotnet_3.1`
  * [`DotNet 3.1-sdk`](/dotnet/3.1-sdk)
    * `ghcr.io/goover/yolks:dotnet_3.1-sdk`
  * [`DotNet 5.0`](/dotnet/5.0)
    * `ghcr.io/goover/yolks:dotnet_5.0`
  * [`DotNet 5.0-sdk`](/dotnet/5.0-sdk)
    * `ghcr.io/goover/yolks:dotnet_5.0-sdk`  
  * [`DotNet 6.0`](/dotnet/6.0)
    * `ghcr.io/goover/yolks:dotnet_6.0`
  * [`DotNet 6.0-sdk`](/dotnet/6.0-sdk)
    * `ghcr.io/goover/yolks:dotnet_6.0-sdk`  

### [Erlang](/erlang)
  * [`erlang22`](/erlang/22)
    * `ghcr.io/goover/yolks:erlang_22`
  * [`erlang23`](/erlang/23)
    * `ghcr.io/goover/yolks:erlang_23`
  * [`erlang24`](/erlang/24)
    * `ghcr.io/goover/yolks:erlang_24`

### [Games](/games)  
  * [`arma3`](/games/arma3)
    * `ghcr.io/goover/games:arma3`
  * [`fivem`](/games/fivem)
	* `ghcr.io/goover/games:fivem`
  * [`rust`](/games/rust)
	* `ghcr.io/goover/games:rust`

### [Golang](/go)
  * [`go1.14`](/go/1.14)
    * `ghcr.io/goover/yolks:go_1.14`
  * [`go1.15`](/go/1.15)
    * `ghcr.io/goover/yolks:go_1.15`
  * [`go1.16`](/go/1.16)
    * `ghcr.io/goover/yolks:go_1.16`

### [Java](/java)
  * [`Java 8`](/java/8)
    * `ghcr.io/goover/yolks:java_8`
  * [`Java 11`](/java/11)
    * `ghcr.io/goover/yolks:java_11`
  * [`Java 16`](/java/16)
    * `ghcr.io/goover/yolks:java_16`
  * [`Java 17`](/java/17)
    * `ghcr.io/goover/yolks:java_17`
  * [`Java 18`](/java/18)
    * `ghcr.io/goover/yolks:java_18`

### [MariaDB](/mariadb)
  * [`MariaDB 10.3`](/mariadb/10.3)
    * `ghcr.io/goover/yolks:mariadb_10.3`
  * [`MariaDB 10.4`](/mariadb/10.4)
    * `ghcr.io/goover/yolks:mariadb_10.4`
  * [`MariaDB 10.5`](/mariadb/10.5)
    * `ghcr.io/goover/yolks:mariadb_10.5`
  * [`MariaDB 10.6`](/mariadb/10.6)
    * `ghcr.io/goover/yolks:mariadb_10.6`
  * [`MariaDB 10.7`](/mariadb/10.7)
    * `ghcr.io/goover/yolks:mariadb_10.7`  

### [MongoDB](/mongodb)
  * [`MongoDB 4`](/mongodb/4)
    * `ghcr.io/goover/yolks:mongodb_4`
  * [`MongoDB 5`](/mongodb/5)
    * `ghcr.io/goover/yolks:mongodb_5`

### [Mono](/mono)
  * [`Mono Latest`](/mono/latest)
    * `ghcr.io/goover/yolks:mono_latest`

### [Nodejs](/nodejs)
  * [`NodeJS 12`](/nodejs/12)
    * `ghcr.io/goover/yolks:nodejs_12`
  * [`NodeJS 14`](/nodejs/14)
    * `ghcr.io/goover/yolks:nodejs_14`
  * [`NodeJS 16`](/nodejs/16)
    * `ghcr.io/goover/yolks:nodejs_16`
  * [`NodeJS 17`](/nodejs/17)
    * `ghcr.io/goover/yolks:nodejs_17`
  * [`NodeJS 18`](/nodejs/18)
    * `ghcr.io/goover/yolks:nodejs_18`  

### [PostgreSQL](/postgres)
  * [`Postgres 9`](/postgres/9)
    * `ghcr.io/goover/yolks:postgres_9`
  * [`Postgres 10`](/postgres/10)
    * `ghcr.io/goover/yolks:postgres_10`
  * [`Postgres 11`](/postgres/11)
    * `ghcr.io/goover/yolks:postgres_11`
  * [`Postgres 12`](/postgres/12)
    * `ghcr.io/goover/yolks:postgres_12`
  * [`Postgres 13`](/postgres/13)
    * `ghcr.io/goover/yolks:postgres_13`
  * [`Postgres 14`](/postgres/14)
    * `ghcr.io/goover/yolks:postgres_14`  

### [Python](/python)
  * [`Python 3.7`](/python/3.7)
    * `ghcr.io/goover/yolks:python_3.7`
  * [`Python 3.8`](/python/3.8)
    * `ghcr.io/goover/yolks:python_3.8`
  * [`Python 3.9`](/python/3.9)
    * `ghcr.io/goover/yolks:python_3.9`
  * [`Python 3.10`](/python/3.9)
    * `ghcr.io/goover/yolks:python_3.10`

### [Redis](/redis)
  * [`Redis 5`](/redis/5)
    * `ghcr.io/goover/yolks:redis_5`
  * [`Redis 6`](/redis/6)
    * `ghcr.io/goover/yolks:redis_6`
    
### [SteamCMD](/steam)
  * [`SteamCMD Debian Latest`](/steamcmd/debian)
    * `ghcr.io/goover/steamcmd_debian`
  * [`SteamCMD Debian 10`](/steamcmd_debian10)
    * `ghcr.io/goover/ames:source_debian10`
  * [`SteamCMD Ubuntu Latest`](/steamcmd_ubuntu)
    * `ghcr.io/goover/steamcmd_ubuntu`   

### [Voice](/voice)
  * [`TeaSpeak`](/teaspeak)
    * `ghcr.io/goover/yolks:voice:teaspeak`

### [Wine](/wine)
  * [`Wine staging`](/wine/staging)
    * `ghcr.io/goover/yolks:wine_staging`
  * [`Wine stable`](/wine/stable)
    * `ghcr.io/goover/yolks:wine_stable`
  * [`Wine devel`](/wine/devel)
    * `ghcr.io/goover/yolks:wine_devel`

### [Installation Images](/installers)
  * [`alpine-install`](/installers/alpine)
    * `ghcr.io/goover/installers:alpine`
  * [`debian-install`](/installers/debian)
    * `ghcr.io/goover/installers:debian`
