[![Docker Pulls](https://img.shields.io/docker/pulls/theanurin/gentoo-sources-bundle?label=Pulls)](https://hub.docker.com/r/theanurin/gentoo-sources-bundle)

# Gentoo Sources Bundle

!!! WARNING: Moving into https://github.com/theanurin/docker-images


Gentoo stage3 based image with set of packages to make ability to compile kernel in few commands via Docker.

## Accept Licenses

You are accepted following licenses by using `amd64` or `i686` image:

- `/var/db/repos/gentoo/licenses/intel-ucode`
- `/var/db/repos/gentoo/licenses/linux-firmware`
- `/var/db/repos/gentoo/licenses/linux-fw-redistributable`

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
docker run --rm --interactive --tty theanurin/gentoo-sources-bundle

# Inside container
make menuconfig
make -j$(nproc)
exit
```


## Quick Start with configuration

```bash
docker run --rm --interactive --tty \
  --mount type=bind,source="$(pwd)",target=/data \ 
  theanurin/gentoo-sources-bundle

# Inside container
ln -s /data/kernel.config .config
make menuconfig
make -j$(nproc)
exit
```



## Image name convention

| Image Tag Name                                          | Build Source                                          |
|---------------------------------------------------------|-------------------------------------------------------|
| theanurin/gentoo-sources-bundle                         | latest build for latest kernel (multi-arch)           |
| theanurin/gentoo-sources-bundle:X                       | latest build for specific kernel (multi-arch)         |
| theanurin/gentoo-sources-bundle:X.Y                     | latest build for specific kernel (multi-arch)         |
| theanurin/gentoo-sources-bundle:X.Y.Z                   | latest build for specific kernel (multi-arch)         |
| theanurin/gentoo-sources-bundle:YYYYMMDD-X.Y.Z          | specific build for specific kernel (multi-arch)       |
| theanurin/gentoo-sources-bundle:ARCH                    | latest build for latest kernel for specific ARCH      |
| theanurin/gentoo-sources-bundle:ARCH-X                  | latest build for specific kernel for specific ARCH    |
| theanurin/gentoo-sources-bundle:ARCH-X.Y                | latest build for specific kernel for specific ARCH    |
| theanurin/gentoo-sources-bundle:ARCH-X.Y.Z              | latest build for specific kernel for specific ARCH    |
| theanurin/gentoo-sources-bundle:YYYYMMDD-ARCH-X.Y.Z     | specific build for specific kernel for specific ARCH  |

## What the image includes

* [sys-kernel/gentoo-sources](https://packages.gentoo.org/packages/sys-kernel/gentoo-sources) package with dependencies

## Developer Notes

```shell
python3 -m venv .venv
source .venv/bin/activate
pip3 install requests beautifulsoup4
pip uninstall urllib3
pip install 'urllib3<2.0'
./tools/gentoo-sources-package-parser.py
```

### Git tag format

Samples:

- `6.1.53-r1/amd64,x86,arm,arm64`
