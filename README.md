[![Docker Build Status](https://img.shields.io/docker/cloud/build/zxteamorg/devel.migration-builder?label=Build%20Status)](https://hub.docker.com/r/zxteamorg/devel.migration-builder/builds)
[![Docker Image Version](https://img.shields.io/docker/v/zxteamorg/devel.migration-builder?sort=date&label=Version)](https://hub.docker.com/r/zxteamorg/devel.migration-builder/tags)
[![Docker Image Size](https://img.shields.io/docker/image-size/zxteamorg/devel.migration-builder?label=Image%20Size)](https://hub.docker.com/r/zxteamorg/devel.migration-builder/tags)
[![Docker Pulls](https://img.shields.io/docker/pulls/zxteamorg/devel.migration-builder?label=Pulls)](https://hub.docker.com/r/zxteamorg/devel.migration-builder)
[![Docker Pulls](https://img.shields.io/docker/stars/zxteamorg/devel.migration-builder?label=Docker%20Stars)](https://hub.docker.com/r/zxteamorg/devel.migration-builder)
[![Docker Automation](https://img.shields.io/docker/cloud/automated/zxteamorg/devel.migration-builder?label=Docker%20Automation)](https://hub.docker.com/r/zxteamorg/devel.migration-builder/builds)

# Migration Builder

*Migration Builder* - is a processor of [Mustache](https://mustache.github.io/) based SQL script templates.

# Image reason

TDB

# Spec

## Environment variables

* `VERSION_FROM` - version from. Default: '',
* `VERSION_TO` - version to. Default: ''.
* `ENV` - a name of target build environment, like: `devel`, `test`, `production`. Default: ''.
* `SOURCE_PATH` - relative path to sources. Default: 'updates'.
* `BUILD_PATH` - relative path to buid artifacts. Default: '.dist'.
* `EXTRA_CONFIGS` - comma-separated list of additional configuration files (relative to `/data` directory). Default: ''.


## ENV Zone Flag

ENV make some magic:

* Render context provides capitalized environment zone flag in format: `isEnvironment${capitalized(ENV)}`
* Use configuratoion file `database-{$ENV}.config`

Examples:
* ENV=production gives `isEnvironmentProduction: true` + read database-production.config
* ENV=test gives `isEnvironmentTest: true` + read database-test.config
* ENV=devel gives `isEnvironmentDevel: true` + read database-devel.config

So you can use something like this:

```sql
--
-- EMULATOR kind will be produced only for non-production environments
--
CREATE TYPE "public"."SERVICE_KIND" AS ENUM (
{{^isEnvironmentProduction}}
	'EMULATOR',
{{/isEnvironmentProduction}}
	'WEBSOCKET'
);
```

## Volumes

* `/data` - Root your database work directory

# Inside

* Alpine Linux
* NodeJS
* Migration Builder JS Script

# Launch

```bash
docker run --interactive --tty --rm --volume /path/to/database/workdir:/data zxteamorg/devel.migration-builder
```

# Support

* Maintained by: [ZXTeam](https://zxteam.org)
* Where to get help: [Telegram Channel](https://t.me/zxteamorg)
