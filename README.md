[![Docker Pulls](https://img.shields.io/docker/pulls/zxteamorg/gentoo-sources-bundle?label=Pulls)](https://hub.docker.com/r/zxteamorg/gentoo-sources-bundle)

# Gentoo Sources Bundle

This image based on Gentoo stage3 with additionally emerged packages to make ability to compile Gentoo Sources Kernel in few commands on a Docker Host.

## Author's Notes

From some point I have to managing a lot of different kernel versions and configurations.
It is a pretty messy if you try to do that on your workstation.
Toolchains always going forward and it is very hard to build old kernels on latest toolchain.
Docker images solve the problem! When you have to update kernel configuration on an old system, just run a container by using proper image (with gentoo-sources and build tools).
All of you need, just manage your kernel configuration files.

## Use Cases

* Build Gentoo kernel out side of a Gentoo machine
* Automate kernel building
* Build oldest kernels (historical)

## Quick Start

```bash
docker run --rm --interactive --tty zxteamorg/gentoo-sources-bundle

# Inside container
make menuconfig
make -j$(nproc)
exit
```

## Image name convention

| Image Tag Name                                          | Build Source                                     |
|---------------------------------------------------------|--------------------------------------------------|
| zxteamorg/gentoo-sources-bundle                         | latest build for latest kernel (multi-arch)      |
| zxteamorg/gentoo-sources-bundle-X.Y.Z                   | latest build for specific kernel (multi-arch)    |
| zxteamorg/gentoo-sources-bundle:YYYYMMDD-X.Y.Z          | specific build for specific kernel (multi-arch)  |
| zxteamorg/gentoo-sources-bundle:amd64                   | latest build for latest kernel (amd64)           |
| zxteamorg/gentoo-sources-bundle:arm32v5                 | latest build for latest kernel (arm/v5)          |
| zxteamorg/gentoo-sources-bundle:arm32v6                 | latest build for latest kernel (arm/v6)          |
| zxteamorg/gentoo-sources-bundle:arm32v7                 | latest build for latest kernel (arm/v7)          |
| zxteamorg/gentoo-sources-bundle:arm64v8                 | latest build for latest kernel (arm64/v8)        |
| zxteamorg/gentoo-sources-bundle:x86                     | latest build for latest kernel (x86)             |
| zxteamorg/gentoo-sources-bundle:amd64-X.Y.Z             | latest build for specific kernel (amd64)         |
| zxteamorg/gentoo-sources-bundle:arm32v5-X.Y.Z           | latest build for specific kernel (arm/v5)        |
| zxteamorg/gentoo-sources-bundle:arm32v6-X.Y.Z           | latest build for specific kernel (arm/v6)        |
| zxteamorg/gentoo-sources-bundle:arm32v7-X.Y.Z           | latest build for specific kernel (arm/v7)        |
| zxteamorg/gentoo-sources-bundle:arm64v8-X.Y.Z           | latest build for specific kernel (arm64/v8)      |
| zxteamorg/gentoo-sources-bundle:x86-X.Y.Z               | latest build for specific kernel (x86)           |
| zxteamorg/gentoo-sources-bundle:YYYYMMDD-amd64-X.Y.Z    | specific build for specific kernel (amd64)       |
| zxteamorg/gentoo-sources-bundle:YYYYMMDD-arm32v5-X.Y.Z  | specific build for specific kernel (arm/v5)      |
| zxteamorg/gentoo-sources-bundle:YYYYMMDD-arm32v6-X.Y.Z  | specific build for specific kernel (arm/v6)      |
| zxteamorg/gentoo-sources-bundle:YYYYMMDD-arm32v7-X.Y.Z  | specific build for specific kernel (arm/v7)      |
| zxteamorg/gentoo-sources-bundle:YYYYMMDD-arm64v8-X.Y.Z  | specific build for specific kernel (arm64/v8)    |
| zxteamorg/gentoo-sources-bundle:YYYYMMDD-x86-X.Y.Z      | specific build for specific kernel (x86)         |

## What the image includes

* [sys-kernel/gentoo-sources](https://packages.gentoo.org/packages/sys-kernel/gentoo-sources) package with dependencies

## Developer Notes

```shell
python3 -m venv .venv
source .venv/bin/activate
pip3 install requests beautifulsoup4
./tools/gentoo-sources-package-parser.py
```
