[![Docker Image Version][15 Docker Image Version]][15 Docker Tags]
[![Docker Image Size][15 Docker Image Size]][15 Docker Tags]
[![GitHub Workflow Status][15 GitHub Workflow Status]][15 GitHub Workflow Log]
[![GitHub Repo Stars]][GitHub Repo Branch]
[![Docker Pulls][15 Docker Pulls]][15 Docker Repo]
[![Docker Stars][15 Docker Stars]][15 Docker Repo]

## PostgreSQL 15 (For Developers)

[PostgreSQL](https://www.postgresql.org/) is a powerful, open source object-relational database system with over 30 years of active development that has earned it a strong reputation for reliability, feature robustness, and performance

## Image reason

For development and testing purposes we need pre-setup Postgres server to automate development and auto-testing activity. The container has pre-defined empty database (with flag table to ensure non-production case) and two users.

## Spec

### Expose ports

* `tcp/5432` - Postgres listening endpoint

### Directories

* `/data` - Hold Postgres'es data
* `/dbseed` - Files `*.sql` from the folder is executing at startup of a container
    * `/dbseed/*.sql` - execute in `devdb` database as `postgres` user
    * `/dbseed/<db_name>/*.sql` - execute in `<db_name>` database as `postgres` user

### Predefined Stuff

* Predefined database `devdb`
* Predefined flag table `"public"."emptytestflag"`
* User `postgres` - superuser (no password)
* User `devadmin` - owner of the database `devdb` (no password)
* User `devuser` - regular user (no password)

## Inside

* Alpine Linux 3.19
* PostgreSQL 15.7 Server

## Launch

1. Start for development

    ```shell
    docker run --interactive --tty --rm --publish 5432:5432 theanurin/devel.postgres-15
    ```

1. Use connection strings (no password):

    * `postgres://postgres@127.0.0.1:5432/postgres` - to login as superuser
    * `postgres://devadmin@127.0.0.1:5432/devdb` - to login as `devdb` owner
    * `postgres://devuser@127.0.0.1:5432/devdb` - to login as regular user

## Build Own Images With Additional Predefined Data

### Based on SQL scripts

In this scenario your init SQL files are placed in `./init-sql` directory and will be applied in alphabetical order.

```dockerfile
FROM theanurin/devel.postgres-15 AS postgres_builder
COPY ./init-sql/ /.builder-postgres.d/
RUN chmod +x /.builder-postgres.sh
RUN /usr/local/bin/docker-builder-postgres-15.sh

FROM theanurin/devel.postgres-15
COPY --from=postgres_builder /build/ /
```

### Based on execution shell script

In this scenario your have to provide shell script `/.builder-postgres.sh` that will execute at build time. The script responsible for data generation.

```shell
#!/bin/sh
#
# sample of generate-data.sh
#

set -e

DB_NAME="my-db"
DB_OWNER="${DB_NAME}-owner"

# Execute command via file using Redirecting Input redirections
psql --dbname=postgres --username=postgres --set user="${DB_OWNER}" --file=<(echo 'CREATE USER :"user" WITH LOGIN;')

# Execute command via Here Documents redirections
psql --dbname=postgres --username=postgres --set db="${DB_NAME}" --set db_owner="${DB_OWNER}" <<-'EOSQL'
    CREATE DATABASE :"db" WITH
    OWNER = :"db_owner" ENCODING = 'UTF8'
    CONNECTION LIMIT = -1;
EOSQL

# Execute command via inline SQL
psql --dbname="${DB_NAME}" --username="${DB_OWNER}" --command='CREATE TABLE "test" ("id" INTEGER NOT NULL);'

echo "Wow, ${DB_NAME} was created successfully!"
```

```dockerfile
FROM theanurin/devel.postgres-15 AS build_stage
COPY ./generate-data.sh /.builder-postgres.sh
RUN /usr/local/bin/docker-builder-postgres-15.sh

FROM theanurin/devel.postgres-15
COPY --from=build_stage /build/ /
```

### Based on state of a container

```shell
# Run container
docker run --detach --name pg_builder --publish 5432:5432 theanurin/devel.postgres-15

# Fill you data into Postgres
./my-data-script.sh postgres://postgres@127.0.0.1:5432/postgres

# Stop container and make new image
docker stop pg_builder
docker commit pg_builder my_devel.postgres-15_with_data

# Use image my_devel.postgres-15_with_data
```


## Support

* Maintained by: [Max Anurin](https://anurin.name/)
* Where to get help: [Telegram](https://t.me/theanurin)

[GitHub Repo Branch]: https://github.com/theanurin/docker-images/tree/devel.postgres
[GitHub Repo Stars]: https://img.shields.io/github/stars/theanurin/docker-images?label=GitHub%20Starts

[15 GitHub Workflow Status]: https://img.shields.io/github/actions/workflow/status/theanurin/docker-images/devel.postgres-15-docker-image-release.yml?label=GitHub%20Workflow
[15 GitHub Workflow Log]: https://github.com/theanurin/docker-images/actions/workflows/devel.postgres-15-docker-image-release.yml
[15 Docker Repo]: https://hub.docker.com/r/theanurin/devel.postgres-15
[15 Docker Image Version]: https://img.shields.io/docker/v/theanurin/devel.postgres-15?sort=date&label=Version
[15 Docker Image Size]: https://img.shields.io/docker/image-size/theanurin/devel.postgres-15?label=Image%20Size
[15 Docker Tags]: https://hub.docker.com/r/theanurin/devel.postgres-15/tags
[15 Docker Stars]: https://img.shields.io/docker/stars/theanurin/devel.postgres-15?label=Docker%20Stars
[15 Docker Pulls]: https://img.shields.io/docker/pulls/theanurin/devel.postgres-15?label=Docker%20Pulls
