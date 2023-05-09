[![Docker Image Version](https://img.shields.io/docker/v/theanurin/subversion?sort=date&label=Version)](https://hub.docker.com/r/theanurin/subversion/tags)
[![Docker Image Size](https://img.shields.io/docker/image-size/theanurin/subversion?label=Image%20Size)](https://hub.docker.com/r/theanurin/subversion/tags)
[![Docker Pulls](https://img.shields.io/docker/pulls/theanurin/subversion?label=Pulls)](https://hub.docker.com/r/theanurin/subversion)
[![Docker Stars](https://img.shields.io/docker/stars/theanurin/subversion?label=Docker%20Stars)](https://hub.docker.com/r/theanurin/subversion)

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

* Alpine Linux 3.18.2
* Apache Subversion 1.14.2-r10

# Launch

```shell
docker run --interactive --tty --rm \
  --publish 3690:3690 \
  theanurin/subversion
```

# Support

* Maintained by: [Max Anurin](https://anurin.name/)
* Where to get help: [Telegram](https://t.me/theanurin)
