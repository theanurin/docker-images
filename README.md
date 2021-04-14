[![Docker Build Status](https://img.shields.io/docker/cloud/build/zxteamorg/contrib.litecoin?label=Build%20Status)](https://hub.docker.com/r/zxteamorg/contrib.litecoin/builds)
[![Docker Image Version](https://img.shields.io/docker/v/zxteamorg/contrib.litecoin?sort=date&label=Version)](https://hub.docker.com/r/zxteamorg/contrib.litecoin/tags)
[![Docker Image Size](https://img.shields.io/docker/image-size/zxteamorg/contrib.litecoin?label=Image%20Size)](https://hub.docker.com/r/zxteamorg/contrib.litecoin/tags)
[![Docker Pulls](https://img.shields.io/docker/pulls/zxteamorg/contrib.litecoin?label=Pulls)](https://hub.docker.com/r/zxteamorg/contrib.litecoin)
[![Docker Pulls](https://img.shields.io/docker/stars/zxteamorg/contrib.litecoin?label=Docker%20Stars)](https://hub.docker.com/r/zxteamorg/contrib.litecoin)
[![Docker Automation](https://img.shields.io/docker/cloud/automated/zxteamorg/contrib.litecoin?label=Docker%20Automation)](https://hub.docker.com/r/zxteamorg/contrib.litecoin/builds)

# Litecoin Full Node

[Litecoin](https://litecoin.org/)

# Image reason

Just a free contribution into Litecoin ecosystem.

# Spec

## Environment variables

No any variables

## Expose ports

* `tcp/9332` - RPC port mainnet
* `tcp/9333` - P2P port mainnet
* `tcp/19332` - RPC port mainnet
* `tcp/19335` - P2P port testnet
* `tcp/19443` - RPC port mainnet
* `tcp/19444` - P2P port regtest

## Volumes

* `/data` - Hold litecoin blockchain data

# Inside

* [Litecoin v0.18.1](https://github.com/litecoin-project/litecoin/tree/v0.18.1)

# Launch

## Mainnet
    ```bash
    docker run \
        --interactive \
        --tty \
        --rm \
        --publish 127.0.0.1:9332:9332 \
        --publish 0.0.0.0:9333:9333 \
        --mount type=bind,source=$PWD/litecoin-data,target=/data \
        zxteamorg/contrib.litecoin
    ```

## Testnet
    ```bash
    docker run \
        --interactive \
        --tty \
        --rm \
        --publish 127.0.0.1:19332:19332 \
        --publish 0.0.0.0:19335:19335 \
        --mount type=bind,source=$PWD/litecoin-data,target=/data \
        zxteamorg/contrib.litecoin \
            -testnet \
            -printtoconsole \
            -datadir=/data \
            -port=9333 \
            -rpcbind=0.0.0.0:9332 \
            -rpcallowip=0.0.0.0/0 \
            -disablewallet
    ```


## Daemon usage help
    ```bash
    docker run \
        --interactive \
        --tty \
        --rm \
        zxteamorg/contrib.litecoin \
            --help
    ```


# Support

* Maintained by: [ZXTeam](https://zxteam.org)
* Where to get help: [Telegram Channel](https://t.me/zxteamorg)
