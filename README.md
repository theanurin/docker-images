[![Docker Image Version][Docker Image Version]][Docker Tags]
[![Docker Image Size][Docker Image Size]][Docker Tags]
[![GitHub Workflow Status][GitHub Workflow Status]][GitHub Workflow Log]
[![GitHub Repo Stars]][GitHub Repo Branch]
[![Docker Pulls][Docker Pulls]][Docker Repo]
[![Docker Stars][Docker Stars]][Docker Repo]

# SQL Migration Runner

This is [SQL Migration](https://docs.freemework.org/sql.misc.migration) runner to execute [bundle](https://docs.freemework.org/sql.misc.migration#bundle)(set) of install/rollback scripts.

Public Image: <https://hub.docker.com/r/theanurin/sqlmigrationrunner>

## Input Directory Tree

In following sample you may see structure of [bundle](https://docs.freemework.org/sql.misc.migration#bundle)(set) of install/rollback scripts.

```
.
├── v0000
│   ├── install
│   │   ├── 00-begin.js
│   │   ├── 10-user-install.sql
│   │   ├── 20-uuid-ext-install.sql
│   │   └── 99-end.js
│   └── rollback
│       ├── 00-begin.js
│       ├── 10-user-rollback.sql
│       ├── 20-uuid-ext-rollback.sql
│       └── 99-end.js
├── v0001
│   ├── install
│   │   └── 50-schemas-install.sql
│   └── rollback
│       └── 50-schemas-rollback.sql
└── v0002
    ├── install
    │   └── 50-tr_block_any_updates.sql
    └── rollback
        └── 50-tr_block_any_updates.sql
```

where `v0000`, `v0001` and `v0002` versions of a database. Choose version naming by your own. `MigrationManager` used alpha-number sorting to define install/rollback sequence.

## Use this container directly

### Environment Variables

| Variable                     | Description                                                                                                              | Example                                                                                                                                                 |
| ---------------------------- | ------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------- |
| DB_URL                       | DB connectivity URI                                                                                                      | `postgres://user@host.docker.internal:5432/emptytestdb`, `mysql://user@host.docker.internal:5432/emptytestdb`, `file+sqlite:///var/myproject/sqlite.db` |
| DB_USER (optional)           | Provide DB role (user) name. Mutually excluded by DB_USER_FILE. Override an user passed in DB_URL                        | SuperUser                                                                                                                                               |
| DB_USER_FILE (optional)      | Provide a path to file where stored DB role (user) name. Mutually excluded by DB_USER. Override an user passed in DB_URL | /run/secret/DbOwnerUser                                                                                                                                 |
| DB_PASSWORD (optional)       | Provide DB role password. Mutually excluded by DB_PASSWORD_FILE. Override an user passed in DB_URL                       | SuperPassword                                                                                                                                           |
| DB_PASSWORD_FILE (optional)  | Provide a path to file where stored user password. Mutually excluded by DB_PASSWORD. Override an user passed in DB_URL   | /run/secret/DbOwnerPassword                                                                                                                             |
| DB_TARGET_VERSION (optional) | Version of database of which `install`/`rollback` process must stop                                                      | v0042                                                                                                                                                   |

### Install

```shell
docker run --rm --tty --interactive \
  --volume /PATH/TO/YOUR/MIGRATION/DIRECTORY:/data \
  --env DB_URL="postgres://postgres@host.docker.internal:5432/emptytestdb" \
  --env DB_TARGET_VERSION="v0042" \
  theanurin/sqlmigrationrunner install
```

Command aliases: `install`, `up`, `migration-up`

### Rollback

```shell
docker run --rm --tty --interactive \
  --env DB_URL="postgres://postgres@host.docker.internal:5432/emptytestdb" \
  --env DB_TARGET_VERSION="v0042" \
  theanurin/sqlmigrationrunner rollback
```

Command aliases: `rollback`, `down`, `migration-down`

## Build standalone, self-executable SQL release image

```Dockerfile
ARG BUILD_CONFIGURATION=production
ARG SQL_MIGRATION_BUILDER_IMAGE=theanurin/sqlmigrationbuilder
ARG SQL_MIGRATION_RUNNER_IMAGE=theanurin/sqlmigrationrunner

FROM ${SQL_MIGRATION_BUILDER_IMAGE} AS sql_builder
ARG BUILD_CONFIGURATION
ARG BUILD_VERSION_FROM
ARG BUILD_VERSION_TO
WORKDIR /build
RUN apk add --no-cache tree
COPY migration ./migration
COPY database.config .
COPY database-${BUILD_CONFIGURATION}.config .
# Compile SQL scripts
RUN ENV="${BUILD_CONFIGURATION}" VERSION_FROM="${BUILD_VERSION_FROM}" VERSION_TO="${BUILD_VERSION_TO}" /usr/local/bin/docker-entrypoint.js
RUN mkdir --parents .stage/usr/local/sqlmigration
# Move compiled artifacts
RUN mv .dist .stage/data
# Generate README.md
RUN (cd .stage/data/ && tree) | sed 's/[[:blank:]]/·/g' > .stage/usr/local/sqlmigration/README.md
# Include RELEASE_NOTES.md
COPY RELEASE_NOTES.md ./.stage/data/


FROM ${SQL_MIGRATION_RUNNER_IMAGE}
COPY --from=sql_builder /build/.stage /
```

[GitHub Repo Branch]: https://github.com/theanurin/docker-images/tree/sqlmigrationrunner
[GitHub Repo Stars]: https://img.shields.io/github/stars/theanurin/docker-images?label=GitHub%20Starts
[GitHub Workflow Status]: https://img.shields.io/github/actions/workflow/status/theanurin/docker-images/sqlmigrationrunner-docker-image-release.yml?label=GitHub%20Workflow
[GitHub Workflow Log]: https://github.com/theanurin/docker-images/actions/workflows/sqlmigrationrunner-docker-image-release.yml
[Docker Repo]: https://hub.docker.com/r/theanurin/sqlmigrationrunner
[Docker Image Version]: https://img.shields.io/docker/v/theanurin/sqlmigrationrunner?sort=date&label=Version
[Docker Image Size]: https://img.shields.io/docker/image-size/theanurin/sqlmigrationrunner?label=Image%20Size
[Docker Tags]: https://hub.docker.com/r/theanurin/sqlmigrationrunner/tags
[Docker Stars]: https://img.shields.io/docker/stars/theanurin/sqlmigrationrunner?label=Docker%20Stars
[Docker Pulls]: https://img.shields.io/docker/pulls/theanurin/sqlmigrationrunner?label=Pulls
