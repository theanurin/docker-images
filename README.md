[![Docker Build Status](https://img.shields.io/docker/cloud/build/zxteamorg/zclassic?label=Build%20Status)](https://hub.docker.com/r/zxteamorg/zclassic/builds)
[![Docker Image Version](https://img.shields.io/docker/v/zxteamorg/zclassic?sort=date&label=Version)](https://hub.docker.com/r/zxteamorg/zclassic/tags)
[![Docker Image Size](https://img.shields.io/docker/image-size/zxteamorg/zclassic?label=Image%20Size)](https://hub.docker.com/r/zxteamorg/zclassic/tags)
[![Docker Pulls](https://img.shields.io/docker/pulls/zxteamorg/zclassic?label=Pulls)](https://hub.docker.com/r/zxteamorg/zclassic)
[![Docker Pulls](https://img.shields.io/docker/stars/zxteamorg/zclassic?label=Docker%20Stars)](https://hub.docker.com/r/zxteamorg/zclassic)
[![Docker Automation](https://img.shields.io/docker/cloud/automated/zxteamorg/zclassic?label=Docker%20Automation)](https://hub.docker.com/r/zxteamorg/zclassic/builds)

# ZClassic Full Node

[ZClassic](https://zclassic.org/)

# Image reason

Just a free contribution into ZClassic ecosystem.

# Spec

## Environment variables

No any variables

## Expose ports

* `tcp/8023` - RPC port
* `tcp/8033` - P2P port

## Volumes

* `/data/.zcash-params` - Hold Zcash zkSNARK parameters
* `/data/.zclassic` - Hold zclassic blockchain data

# Inside

* [ZClassic v2.1.1-2](https://github.com/ZclassicCommunity/zclassic/tree/v2.1.1-2)

# Launch
1. Start node daemon
	```bash
	docker run \
		--interactive \
		--tty \
		--rm \
		--publish 127.0.0.1:8023:8023 \
		--publish 0.0.0.0:8033:8033 \
		--mount type=bind,source=$PWD/zclassic-params,target=/data/.zcash-params \
  		--mount type=bind,source=$PWD/zclassic,target=/data/.zclassic \
		zxteamorg/zclassic
	```

# Support

* Maintained by: [ZXTeam](https://zxteam.org)
* Where to get help: [Telegram Channel](https://t.me/zxteamorg)
