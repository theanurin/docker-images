[![Docker Image Version](https://img.shields.io/docker/v/theanurin/sqlmigrationrunner?sort=date&label=Version)](https://hub.docker.com/r/theanurin/sqlmigrationrunner/tags)
[![Docker Image Size](https://img.shields.io/docker/image-size/theanurin/sqlmigrationrunner?label=Image%20Size)](https://hub.docker.com/r/theanurin/sqlmigrationrunner/tags)
[![Docker Pulls](https://img.shields.io/docker/pulls/theanurin/sqlmigrationrunner?label=Pulls)](https://hub.docker.com/r/theanurin/sqlmigrationrunner)
[![Docker Stars](https://img.shields.io/docker/stars/theanurin/sqlmigrationrunner?label=Docker%20Stars)](https://hub.docker.com/r/theanurin/sqlmigrationrunner)

# SQL Migration Runner

This is [SQL Migration](https://docs.freemework.org/sql.misc.migration) runner to execute [bundle](https://docs.freemework.org/sql.misc.migration#bundle)(set) of install/rollback scripts.

Public Image: https://hub.docker.com/r/theanurin/sqlmigrationrunner

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

### Install

```shell
docker run --rm --tty --interactive \
  --volume /PATH/TO/YOUR/MIGRATION/DIRECTORY:/data \
  --env POSTGRES_URL="postgres://postgres@host.docker.internal:5432/emptytestdb" \
  --env DB_TARGET_VERSION="v0042" \
  theanurin/sqlmigrationrunner install
```

Note: `DB_TARGET_VERSION` is optional. Install latest version, if omitted.


### Rollback

```shell
docker run --rm --tty --interactive \
  --env POSTGRES_URL="postgres://postgres@host.docker.internal:5432/emptytestdb" \
  --env DB_TARGET_VERSION="v0042" \
  theanurin/sqlmigrationrunner rollback
```

Note: `DB_TARGET_VERSION` is optional. Rollback all versions, if omitted.

### Advanced (use secret files instead env vars)

Instead passing `POSTGRES_URL` via `--env` you may bind a volume with [secret files](https://docs.docker.com/engine/swarm/secrets/) named `postgres.url` directory:

- `/etc/sqlmigration/secrets`
- `/run/secrets`

Expected secrets directory tree:

```
/run/secrets
├── ...
├── postgres.url
└── ...
```


## Use this container to build standalone SQL release container

TBD
