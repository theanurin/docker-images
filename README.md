[![Docker Build Status](https://img.shields.io/docker/cloud/build/zxteamorg/devel.protobuf?label=Build%20Status)](https://hub.docker.com/r/zxteamorg/devel.protobuf/builds)
[![Docker Image Version](https://img.shields.io/docker/v/zxteamorg/devel.protobuf?sort=date&label=Version)](https://hub.docker.com/r/zxteamorg/devel.protobuf/tags)
[![Docker Image Size](https://img.shields.io/docker/image-size/zxteamorg/devel.protobuf?label=Image%20Size)](https://hub.docker.com/r/zxteamorg/devel.protobuf/tags)
[![Docker Pulls](https://img.shields.io/docker/pulls/zxteamorg/devel.protobuf?label=Pulls)](https://hub.docker.com/r/zxteamorg/devel.protobuf)
[![Docker Pulls](https://img.shields.io/docker/stars/zxteamorg/devel.protobuf?label=Docker%20Stars)](https://hub.docker.com/r/zxteamorg/devel.protobuf)
[![Docker Automation](https://img.shields.io/docker/cloud/automated/zxteamorg/devel.protobuf?label=Docker%20Automation)](https://hub.docker.com/r/zxteamorg/devel.protobuf/builds)

# Protocol buffers

[Protocol buffers](https://developers.google.com/protocol-buffers) are a language-neutral, platform-neutral extensible mechanism for serializing structured data.

# Image reason

`Protoc` is a native tool to generate protocol buffer binding. The image provide quick and straight forward way to generate necessary sources on any developer's workstation.

# Spec

## Environment variables

* `VERBOSE` = yes|no - Show executed shell commands. Default: no

## Volumes

No any volumes

# Inside

* [Alpine Linux 3.12.0](https://hub.docker.com/_/alpine)
* [Protocol Buffers v3.13.0](https://github.com/protocolbuffers/protobuf/releases/tag/v3.13.0)
* [NodeJS](https://nodejs.org/)
* Entry point shell script to simplify launch

# Launch

## Generate C# bindings (--target=csharp)

```bash
docker run --interactive --tty --rm --volume /path/to/proto:/data/in --volume /path/to/src.gen:/data/out zxteamorg/devel.protobuf --target=csharp
```

## Generate TypeScript bindings (--target=typescript)

```bash
docker run --interactive --tty --rm --volume /path/to/proto:/data/in --volume /path/to/src.gen:/data/out zxteamorg/devel.protobuf --target=typescript
```

# Support

* Maintained by: [ZXTeam](https://zxteam.org)
* Where to get help: [Telegram Channel](https://t.me/zxteamorg)
