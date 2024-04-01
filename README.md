# Pterodactyl-Images (Yolks)
Docker Images for the Hosting Panel Pterodactyl created by gOOvER

A curated collection of core images that can be used with Pterodactyl's Egg system. Each image is rebuilt
periodically to ensure dependencies are always up-to-date.

All of these images are available for `linux/amd64` and `linux/arm64` versions, unless otherwise specified, to use
these images on an arm system, no modification to them or the tag is needed, they should just work.
---

> [!NOTE]
> You can view all images available here: https://github.com/goover/images/pkgs/container/images

## ➡️ Image usage uris

## ➡️ NodeJS
| Image              | Status                                                                                                                                                          | Description                                            |
| ------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------ |
| `goover/nodejs` | [![build nodejs](https://github.com/goover/images/actions/workflows/nodejs_github.yml/badge.svg)](https://github.com/goover/images/actions/workflows/nodejs_github.yml) | NodeJS versions from `12` to `20`.

| Image            | URI                                    | AMD64 | ARM64 |
| ---------------- | -------------------------------------- | ------| ----- |
| nodejs:12    | `ghcr.io/goover/nodejs:12` | ✅ | ✅ |
| nodejs:14    | `ghcr.io/goover/nodejs:14` | ✅ | ✅ |
| nodejs:16    | `ghcr.io/goover/nodejs:16` | ✅ | ✅ |
| nodejs:18    | `ghcr.io/goover/nodejs:18` | ✅ | ✅ |
| nodejs:20    | `ghcr.io/goover/nodejs:20` | ✅ | ✅ |
| nodejs:21    | `ghcr.io/goover/nodejs:21` | ✅ | ✅ |

## ➡️ GO
| Image              | Status                                                                                                                                                          | Description                                            |
| ------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------ |
| `goover/go` | [![build go ](https://github.com/goover/images/actions/workflows/nodejs_github.yml/badge.svg)](https://github.com/goover/images/actions/workflows/dev-go.yml) | GO versions from `1.14` to `1.22`.

| Image            | URI                                    | AMD64 | ARM64 |
| ---------------- | -------------------------------------- | ------| ----- |
| go:1.14ㅤㅤ      | `ghcr.io/goover/go:1.14`ㅤ ㅤ           |  ✅  |   ✅  |
| go:1.15 ㅤㅤ     | `ghcr.io/goover/go:1.15`ㅤ ㅤ           |  ✅  |   ✅  |
| go:1.16   ㅤㅤ   | `ghcr.io/goover/go:1.16`ㅤㅤ  | ✅ | ✅ |
| go:1.17   ㅤㅤ   | `ghcr.io/goover/go:1.17`ㅤㅤ  | ✅ | ✅ |
| go:1.18  ㅤㅤ    | `ghcr.io/goover/go:1.18`ㅤㅤ  | ✅ | ✅ |
| go:1.19  ㅤㅤ    | `ghcr.io/goover/go:1.19`ㅤㅤ  | ✅ | ✅ |
| go:1.20  ㅤㅤ    | `ghcr.io/goover/go:1.20`ㅤ ㅤ | ✅ | ✅ |
| go:1.21  ㅤㅤ    | `ghcr.io/goover/go:1.21`ㅤ ㅤ | ✅ | ✅ |
| go:1.22  ㅤㅤ    | `ghcr.io/goover/go:1.22`ㅤ ㅤ | ✅ | ✅ |

## ➡️ Python
| Image              | Status                                                                                                                                                          | Description                                            |
| ------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------ |
| `goover/python` | [![build python ](https://github.com/goover/images/actions/workflows/nodejs_github.yml/badge.svg)](https://github.com/goover/images/actions/workflows/dev-python.yml) | Python versions from `3.7` to `3.11`.

| Image            | URI                                    | AMD64 | ARM64 |
| ---------------- | -------------------------------------- | ------| ----- |
| python:3.7ㅤ   | `ghcr.io/goover/images:python_3.7`  |  |  |
| python:3.8ㅤ   | `ghcr.io/goover/images:python_3.8`  |  |  |
| python:3.9 ㅤ  | `ghcr.io/goover/images:python_3.9`  |  |  |
| python:3.10ㅤ  | `ghcr.io/goover/images:python_3.10` |  |  |
| python:3.11 ㅤ | `ghcr.io/goover/images:python_3.11` |  |  |