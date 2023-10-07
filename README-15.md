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
* `/updates` - Files `*.sql` from the folder is executing at startup of a container
    * `/updates/*.sql` - execute in `devdb` as `postgres` user
    * `/updates/<db_name>/*.sql` - execute in `<db_name>` as `postgres` user

### Predefined Stuff

* Database `devdb`
* Flag table `"public"."emptytestflag"`
* User `postgres` - superuser (no password)
* User `devadmin` - owner of the database `devdb` (no password)
* User `devuser` - regular user (no password)

## Inside

* Alpine Linux 3.18.4
* PostgreSQL 15.4 Server

# Launch

1. Start for development

    ```shell
    docker run --interactive --tty --rm --publish 5432:5432 theanurin/devel.postgres-15
    ```

1. Use connection strings (no password):

    * `postgres://postgres@127.0.0.1:5432/postgres` - to login as superuser
    * `postgres://devadmin@127.0.0.1:5432/devdb` - to login as `devdb` owner
    * `postgres://devuser@127.0.0.1:5432/devdb` - to login as regular user

# Support

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
