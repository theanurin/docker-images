[![Docker Image Version](https://img.shields.io/docker/v/theanurin/zclassic?sort=date&label=Version)](https://hub.docker.com/r/theanurin/zclassic/tags)
[![Docker Image Size](https://img.shields.io/docker/image-size/theanurin/zclassic?label=Image%20Size)](https://hub.docker.com/r/theanurin/zclassic/tags)
[![Docker Pulls](https://img.shields.io/docker/pulls/theanurin/zclassic?label=Pulls)](https://hub.docker.com/r/theanurin/zclassic)
[![Docker Stars](https://img.shields.io/docker/stars/theanurin/zclassic?label=Docker%20Stars)](https://hub.docker.com/r/theanurin/zclassic)

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

* [ZClassic v2.1.1-3](https://github.com/ZclassicCommunity/zclassic/tree/v2.1.1-3)

# Launch

## Mainnet

1. Create directories (for mount)
    ```bash
    mkdir zclassic zclassic-params
    ```
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
        theanurin/zclassic
    ```

# Support

* Maintained by: [Max Anurin](https://anurin.name/)
* Where to get help: [Telegram](https://t.me/theanurin)
