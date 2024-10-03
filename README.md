[![Docker Image Version](https://img.shields.io/docker/v/theanurin/tonos-cli?sort=date&label=Version)](https://hub.docker.com/r/theanurin/tonos-cli/tags)
[![Docker Image Size](https://img.shields.io/docker/image-size/theanurin/tonos-cli?label=Image%20Size)](https://hub.docker.com/r/theanurin/tonos-cli/tags)
[![Docker Pulls](https://img.shields.io/docker/pulls/theanurin/tonos-cli?label=Pulls)](https://hub.docker.com/r/theanurin/tonos-cli)
[![Docker Stars](https://img.shields.io/docker/stars/theanurin/tonos-cli?label=Docker%20Stars)](https://hub.docker.com/r/theanurin/tonos-cli)


# TON OS command line tool

[tonos-cli](https://github.com/tonlabs/tonos-cli) is a command line interface utility designed to work with TON blockchain.

# Image reason

Just a free contribution into Free TON ecosystem.

# Spec

The image is built as command line tool (`tonos-cli` as entrypoint) to be able to use as alias on host system.

## Volumes

* `/data` - default work (current) directory for `tonos-cli`. Used for share configs, keys, etc...

# Inside

* [tonos-cli v0.13.0](https://github.com/tonlabs/tonos-cli/releases/tag/v0.13.0)

# Launch

## Test

```shell
docker run --interactive --tty --rm theanurin/tonos-cli
```

## Usage

First, you have to create a directory on a host for configs, keys, etc... (using `.tonos-cli-data` inside home directory in example bellow)

```shell
mkdir "${HOME}/.tonos-cli-data"
```

It is pretty cool to make alias like:

```shell
alias tonos-cli='docker run --interactive --tty --rm --mount "type=bind,source=${HOME}/.tonos-cli-data,target=/data" theanurin/tonos-cli'
alias tonos-cli='docker run --interactive --tty --rm --mount "type=bind,source=${PWD}/.tonos.local,target=/data" theanurin/tonos-cli:alpine'

tonos-cli --help
tonos-cli [subcommand args]
```

# Support

* Maintained by: [Max Anurin](https://anurin.name/)
* Where to get help: [Telegram](https://t.me/theanurin)

# Sample Test Sequence

1. Prepare test environment by creating data directory, generate config for test network and download SafeMultisigWallet contract.
    ```shell
    mkdir "${HOME}/.tonos-cli-data-simpletest"
    cd "${HOME}/.tonos-cli-data-simpletest"
    alias tonos-cli='docker run --interactive --tty --rm --mount "type=bind,source=${HOME}/.tonos-cli-data-simpletest,target=/data" theanurin/tonos-cli'

    # Generate configuration file tonos-cli.conf.json
    tonos-cli config

    # Download contract
    wget https://raw.githubusercontent.com/tonlabs/ton-labs-contracts/776bc3d614ded58330577167313a9b4f80767f41/solidity/safemultisig/SafeMultisigWallet.abi.json
    wget https://raw.githubusercontent.com/tonlabs/ton-labs-contracts/776bc3d614ded58330577167313a9b4f80767f41/solidity/safemultisig/SafeMultisigWallet.tvc

    # Self check
    cat ./tonos-cli.conf.json
    cat ./SafeMultisigWallet.abi.json
    sha1sum ./SafeMultisigWallet.abi.json # Expected: 1c33f77ca18d2cedee23f3e78596fab0ce9f1b33
    sha1sum ./SafeMultisigWallet.tvc # Expected: 7c5605a0d12637309cd5f57330af76e971c76a3b
    ```
    Of coure, you may use own contract instead [SafeMultisigWallet](https://github.com/tonlabs/ton-labs-contracts/tree/776bc3d614ded58330577167313a9b4f80767f41/solidity/safemultisig).
2. Genrarate your keypair
    ```shell
    tonos-cli genphrase
    tonos-cli getkeypair ./keyfile.json '<Seed phrase of previous command>'

    # Self check
    cat ./keyfile.json
    ```
    Of coure, you may use own keypair.
3. Deploy `SafeMultisigWallet` contract
    ```shell
    # Obtain account (address)
    tonos-cli genaddr --setkey keyfile.json ./SafeMultisigWallet.tvc ./SafeMultisigWallet.abi.json

    # Double check that account is Uninit
    tonos-cli account 0:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

    # THERE YOU HAVE TO MAKE LITTLE DEPOSIT TO THE ACCOUNT (because deployment requires fee)

    # Deploy contract (with single owner). Where yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy is "public" field from your ./keyfile.json
    tonos-cli deploy --sign keyfile.json --abi ./SafeMultisigWallet.abi.json ./SafeMultisigWallet.tvc \
    '{"owners":["0xyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy"],"reqConfirms":1}'
    ```
4. Enjoy