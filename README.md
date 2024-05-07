[![Docker Image Version][Docker Image Version]][Docker Tags]
[![Docker Image Size][Docker Image Size]][Docker Tags]
[![GitHub Workflow Status][GitHub Workflow Status]][GitHub Workflow Log]
[![GitHub Repo Stars]][GitHub Repo Branch]
[![Docker Pulls][Docker Pulls]][Docker Repo]
[![Docker Stars][Docker Stars]][Docker Repo]

# SQL Migration Builder

*SQL Migration Builder* - is a processor of [Mustache](https://mustache.github.io/) based SQL script templates.

# Image reason

TDB

# Spec

## Environment variables

* `VERSION_FROM` - version from. Default: '',
* `VERSION_TO` - version to. Default: ''.
* `ENV` - a name of target build environment, like: `devel`, `test`, `production`. Default: ''.
* `SOURCE_PATH` - relative path to sources. Default: 'migration'.
* `BUILD_PATH` - relative path to build artifacts. Default: '.dist'.
* `EXTRA_CONFIGS` - comma-separated list of additional configuration files (relative to `/data` directory). Default: ''.


## Little bit of "magic"

### ENV make some magic

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

### Accessors `'s`, `$root` and `$parent`

- extension `s` - refer to the property s array
- `$root` - refer root data context
- `$parent` - refer parent data context

Example:

```sql
-- database.schema.common.name = common
-- database.schema.audit.name  = audit
--
-- database.user.readonly = "db_ro_user"
--

-- Here we iterate all schema as array. database.schemas - refers to array with all database.schema entries.
{{#database.schemas}}
CREATE SCHEMA "{{ name }}";
COMMENT ON SCHEMA "{{ name }}" IS '{{ desc }}';

-- Mustache doesn't allow you to refer to parent objects.
-- By this "magic" you are able to refer root data context
GRANT USAGE ON SCHEMA "{{ name }}" TO "{{$root.database.user.readonly}}";

-- Mustache doesn't allow you to refer to parent objects.
-- By this "magic" you are able to refer parent data context.
GRANT USAGE ON SCHEMA "{{ name }}" TO "{{$parent.user.readonly}}";
{{/database.schemas}}
```

## Volumes

* `/data` - Root your database work directory

# Inside

* Alpine Linux
* NodeJS
* Migration Builder JS Script

# Launch

```bash
docker run --interactive --tty --rm --volume /path/to/database/workdir:/data theanurin/sqlmigrationbuilder
```

# Support

* Maintained by: [ZXTeam](https://zxteam.org)
* Where to get help: [Telegram Channel](https://t.me/zxteamorg)


[GitHub Repo Branch]: https://github.com/theanurin/docker-images/tree/sqlmigrationbuilder
[GitHub Repo Stars]: https://img.shields.io/github/stars/theanurin/docker-images?label=GitHub%20Starts
[GitHub Workflow Status]: https://img.shields.io/github/actions/workflow/status/theanurin/docker-images/sqlmigrationbuilder-docker-image-release.yml?label=GitHub%20Workflow
[GitHub Workflow Log]: https://github.com/theanurin/docker-images/actions/workflows/sqlmigrationbuilder-docker-image-release.yml
[Docker Repo]: https://hub.docker.com/r/theanurin/sqlmigrationbuilder
[Docker Image Version]: https://img.shields.io/docker/v/theanurin/sqlmigrationbuilder?sort=date&label=Version
[Docker Image Size]: https://img.shields.io/docker/image-size/theanurin/sqlmigrationbuilder?label=Image%20Size
[Docker Tags]: https://hub.docker.com/r/theanurin/sqlmigrationbuilder/tags
[Docker Stars]: https://img.shields.io/docker/stars/theanurin/sqlmigrationbuilder?label=Docker%20Stars
[Docker Pulls]: https://img.shields.io/docker/pulls/theanurin/sqlmigrationbuilder?label=Pulls
