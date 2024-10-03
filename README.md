[![Docker Image Version](https://img.shields.io/docker/v/theanurin/litecoin?sort=date&label=Version)](https://hub.docker.com/r/theanurin/litecoin/tags)
[![Docker Image Size](https://img.shields.io/docker/image-size/theanurin/litecoin?label=Image%20Size)](https://hub.docker.com/r/theanurin/litecoin/tags)
[![Docker Pulls](https://img.shields.io/docker/pulls/theanurin/litecoin?label=Pulls)](https://hub.docker.com/r/theanurin/litecoin)
[![Docker Stars](https://img.shields.io/docker/stars/theanurin/litecoin?label=Docker%20Stars)](https://hub.docker.com/r/theanurin/litecoin)

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

1. Create directories (for mount)
    ```shell
    mkdir litecoin-mainnet-data
    ```
2. Start a container
    ```shell
    docker run \
        --interactive \
        --tty \
        --rm \
        --publish 127.0.0.1:9332:9332 \
        --publish 0.0.0.0:9333:9333 \
        --mount type=bind,source=$PWD/litecoin-mainnet-data,target=/data \
        theanurin/litecoin
    ```

## Testnet

1. Create directories (for mount)
    ```shell
    mkdir litecoin-testnet-data
    ```
2. Start a container
    ```shell
    docker run \
        --interactive \
        --tty \
        --rm \
        --publish 127.0.0.1:19332:19332 \
        --publish 0.0.0.0:19335:19335 \
        --mount type=bind,source=$PWD/litecoin-testnet-data,target=/data \
        theanurin/litecoin \
            -testnet \
            -printtoconsole \
            -datadir=/data \
            -port=9333 \
            -rpcbind=0.0.0.0:9332 \
            -rpcallowip=0.0.0.0/0 \
            -disablewallet
    ```

## Daemon usage help

```shell
docker run \
    --interactive \
    --tty \
    --rm \
    theanurin/litecoin \
        --help
```


# Support

* Maintained by: [Max Anurin](https://anurin.name/)
* Where to get help: [Telegram](https://t.me/theanurin)
