[![Docker Image Version](https://img.shields.io/docker/v/theanurin/configuration-templates?sort=date&label=Version)](https://hub.docker.com/r/theanurin/configuration-templates/tags)
[![Docker Image Size](https://img.shields.io/docker/image-size/theanurin/configuration-templates?label=Image%20Size)](https://hub.docker.com/r/theanurin/configuration-templates/tags)
[![Docker Pulls](https://img.shields.io/docker/pulls/theanurin/configuration-templates?label=Pulls)](https://hub.docker.com/r/theanurin/configuration-templates)
[![Docker Stars](https://img.shields.io/docker/stars/theanurin/configuration-templates?label=Docker%20Stars)](https://hub.docker.com/r/theanurin/configuration-templates)

# Configuration Templates

*Configuration Templates* - is a set of template processors that run against configuration properties.

# Image reason

TDB

## Spec

### Environment variables

**No any variables**

### Volumes

* `/data` - Configuration files root

### Cmd Args

Command arguments apply a configuration source:

* `--config-file=common.config` - source properties from plain key=value file. May used multiple times.
* `--config-toml-file=common.toml` - source properties from TOML configuration file. May used multiple times.
* `--config-env` - source properties from environment variables

## Inside


* Alpine Linux
* NodeJS
* Template Engines:
	* [Mustache](https://mustache.github.io/)
	* TBD
* Entrypoint JS Script

## Launch

```shell
echo "<h1>Hello, {{NAME}} {{?SURNAME}}</h1>" | docker run \
    --interactive --rm \
    --env NAME="World" \
    zxteamorg/devel.configuration-templates \
      --engine mustache \
      --config-env
```


```shell
echo "<h1>Hello, {{NAME}} {{?SURNAME}}</h1>" | \
  docker run \
    --interactive --rm \
    --volume /path/to/configs:/data \
    --env NAME="World" \
    zxteamorg/devel.configuration-templates \
      --engine mustache \
      --config-file=common.config \
      --config-file=devel.config \
      --config-toml-file=devel.toml \
      --config-env
```

## Magic symbols

* Symbol "?" - treat the property as optional(by default properites are mandatory).

## Support

* Maintained by: [ZXTeam](https://zxteam.org)
* Where to get help: [Telegram Channel](https://t.me/zxteamorg)
