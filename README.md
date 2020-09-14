[![Docker Build Status](https://img.shields.io/docker/cloud/build/zxteamorg/infra.subversion?label=Build%20Status)](https://hub.docker.com/r/zxteamorg/infra.subversion/builds)
[![Docker Image Version](https://img.shields.io/docker/v/zxteamorg/infra.subversion?sort=date&label=Version)](https://hub.docker.com/r/zxteamorg/infra.subversion/tags)
[![Docker Image Size](https://img.shields.io/docker/image-size/zxteamorg/infra.subversion?label=Image%20Size)](https://hub.docker.com/r/zxteamorg/infra.subversion/tags)
[![Docker Pulls](https://img.shields.io/docker/pulls/zxteamorg/infra.subversion?label=Pulls)](https://hub.docker.com/r/zxteamorg/infra.subversion)
[![Docker Pulls](https://img.shields.io/docker/stars/zxteamorg/infra.subversion?label=Docker%20Stars)](https://hub.docker.com/r/zxteamorg/infra.subversion)
[![Docker Automation](https://img.shields.io/docker/cloud/automated/zxteamorg/infra.subversion?label=Docker%20Automation)](https://hub.docker.com/r/zxteamorg/infra.subversion/builds)

# Subversion

Apache [Subversion](https://subversion.apache.org/) is a software versioning and revision control system distributed as open source under the Apache License. Software developers use Subversion to maintain current and historical versions of files such as source code, web pages, and documentation.

# Image reason

No special any reason. This just our infrastructure image.

# Spec

## Environment variables

No any variables

## Expose ports

* `tcp/3690` - Subversion listening endpoint

## Volumes

* `/data` - Root of the Subversion repositories

# Inside

* Alpine Linux 3.11.3
* Apache Subversion 1.12.2

# Launch

```bash
docker run --interactive --tty --rm --publish 3690:3690 zxteamorg/infra.subversion
```

# Support

* Maintained by: [ZXTeam](https://zxteam.org)
* Where to get help: [Telegram Channel](https://t.me/zxteamorg)
