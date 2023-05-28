[![Docker Image Version](https://img.shields.io/docker/v/theanurin/devel.postgres-13?sort=date&label=Version)](https://hub.docker.com/r/theanurin/devel.postgres-13/tags)
[![Docker Image Size](https://img.shields.io/docker/image-size/theanurin/devel.postgres-13?label=Image%20Size)](https://hub.docker.com/r/theanurin/devel.postgres-13/tags)
[![Docker Pulls](https://img.shields.io/docker/pulls/theanurin/devel.postgres-13?label=Pulls)](https://hub.docker.com/r/theanurin/devel.postgres-13)
[![Docker Stars](https://img.shields.io/docker/stars/theanurin/devel.postgres-13?label=Docker%20Stars)](https://hub.docker.com/r/theanurin/devel.postgres-13)

# Postgres 13

[PostgreSQL](https://www.postgresql.org/) is a powerful, open source object-relational database system with over 30 years of active development that has earned it a strong reputation for reliability, feature robustness, and performance

# Image reason

For development and testing purposes we need pre-setup Postgres server to automate development and auto-testing activity. The container has pre-defined empty database (with flag table to ensure non-production case) and two users.

# Spec

## Environment variables

No any variables

## Expose ports

* `tcp/5432` - Postgres listening endpoint

## Volumes

* `/data` - Hold Postgres'es data

# Inside

* Alpine Linux 3.16.5
* PostgreSQL 13.11 Server
* Database `devdb`
* Flag table `"public"."emptytestflag"`
* User `postgres` - superuser (no password)
* User `devadmin` - owner of the database `devdb` (no password)
* User `devuser` - regular user (no password)

# Launch
1. Start development server
	```bash
	docker run --interactive --tty --rm --publish 5432:5432 theanurin/devel.postgres-13
	```
1. Use connection strings (no password):
	* `postgres://postgres@127.0.0.1:5432/postgres` - to login as superuser
	* `postgres://devadmin@127.0.0.1:5432/devdb` - to login as `devdb` owner
	* `postgres://devuser@127.0.0.1:5432/devdb` - to login as regular user

# Support

* Maintained by: [Max Anurin](https://anurin.name/)
* Where to get help: [Telegram](https://t.me/theanurin)
