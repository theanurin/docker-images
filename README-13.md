[![Docker Image Version][13 Docker Image Version]][13 Docker Tags]
[![Docker Image Size][13 Docker Image Size]][13 Docker Tags]
[![GitHub Workflow Status][13 GitHub Workflow Status]][13 GitHub Workflow Log]
[![GitHub Repo Stars]][GitHub Repo Branch]
[![Docker Pulls][13 Docker Pulls]][13 Docker Repo]
[![Docker Stars][13 Docker Stars]][13 Docker Repo]

## PostgreSQL 13 (For Developers)

[PostgreSQL](https://www.postgresql.org/) is a powerful, open source object-relational database system with over 30 years of active development that has earned it a strong reputation for reliability, feature robustness, and performance

## Image reason

For development and testing purposes we need pre-setup Postgres server to automate development and auto-testing activity. The container has pre-defined empty database (with flag table to ensure non-production case) and two users.

## Spec

### Expose ports

* `tcp/5432` - Postgres listening endpoint

### Directories

* `/data` - Hold Postgres'es data
* `/dbseed` - Files `*.sql` from the folder is executing at startup of a container
    * `/dbseed/*.sql` - execute in `devdb` as `postgres` user
    * `/dbseed/<db_name>/*.sql` - execute in `<db_name>` as `postgres` user

### Predefined Stuff

* Database `devdb`
* Flag table `"public"."emptytestflag"`
* User `postgres` - superuser (no password)
* User `devadmin` - owner of the database `devdb` (no password)
* User `devuser` - regular user (no password)

## Inside

* Alpine Linux 3.16.8
* PostgreSQL 13.13 Server

## Launch

1. Start for development

    ```shell
    docker run --interactive --tty --rm --publish 5432:5432 theanurin/devel.postgres-13
    ```

1. Use connection strings (no password):

    * `postgres://postgres@127.0.0.1:5432/postgres` - to login as superuser
    * `postgres://devadmin@127.0.0.1:5432/devdb` - to login as `devdb` owner
    * `postgres://devuser@127.0.0.1:5432/devdb` - to login as regular user

## Build Own Images With Additional Predefined Data

### Based On SQL scripts

```dockerfile
FROM theanurin/devel.postgres-13 AS postgres_builder
COPY init-sql/ /.postgres-init-sql/
RUN /usr/local/bin/docker-builder-postgres-13.sh

FROM theanurin/devel.postgres-13
COPY --from=postgres_builder /build/ /
```

### Based on state of a container

```shell
docker commit <container_id/name> <image_repo:image_tag>

# Use image <image_repo:image_tag>
```

## Support

* Maintained by: [Max Anurin](https://anurin.name/)
* Where to get help: [Telegram](https://t.me/theanurin)

[GitHub Repo Branch]: https://github.com/theanurin/docker-images/tree/devel.postgres
[GitHub Repo Stars]: https://img.shields.io/github/stars/theanurin/docker-images?label=GitHub%20Starts

[13 GitHub Workflow Status]: https://img.shields.io/github/actions/workflow/status/theanurin/docker-images/devel.postgres-13-docker-image-release.yml?label=GitHub%20Workflow
[13 GitHub Workflow Log]: https://github.com/theanurin/docker-images/actions/workflows/devel.postgres-13-docker-image-release.yml
[13 Docker Repo]: https://hub.docker.com/r/theanurin/devel.postgres-13
[13 Docker Image Version]: https://img.shields.io/docker/v/theanurin/devel.postgres-13?sort=date&label=Version
[13 Docker Image Size]: https://img.shields.io/docker/image-size/theanurin/devel.postgres-13?label=Image%20Size
[13 Docker Tags]: https://hub.docker.com/r/theanurin/devel.postgres-13/tags
[13 Docker Stars]: https://img.shields.io/docker/stars/theanurin/devel.postgres-13?label=Docker%20Stars
[13 Docker Pulls]: https://img.shields.io/docker/pulls/theanurin/devel.postgres-13?label=Docker%20Pulls
