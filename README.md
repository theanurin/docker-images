[![Docker Image Version](https://img.shields.io/docker/v/theanurin/sqlrunner?sort=date&label=Version)](https://hub.docker.com/r/theanurin/sqlrunner/tags)
[![Docker Image Size](https://img.shields.io/docker/image-size/theanurin/sqlrunner?label=Image%20Size)](https://hub.docker.com/r/theanurin/sqlrunner/tags)
[![Docker Pulls](https://img.shields.io/docker/pulls/theanurin/sqlrunner?label=Pulls)](https://hub.docker.com/r/theanurin/sqlrunner)
[![Docker Stars](https://img.shields.io/docker/stars/theanurin/sqlrunner?label=Docker%20Stars)](https://hub.docker.com/r/theanurin/sqlrunner)

# SQL Runner

*SQL Runner* - provides ability to run series of SQL scripts against variours databases like MSSQL, MySQL, PostgreSQL, SQLite, etc.

## Status

| Server        | Rediness            |
|---------------|---------------------|
| MSSQL         | :x:                 |
| MySQL         | :x:                 |
| PostgreSQL    | :white_check_mark:  |
| SQLite        | :x:                 |

## Image reason

* Base image for self-execution SQL jobs. To embed into CD processes.
* Apply series of SQL scripts for development purposes


## Spec

### Environment variables

* `DATABASE_URL` - URL representation of connection string
	* mysql://user:password@host-or-ip:port/dbname
	* postgres://user:password@host-or-ip:port/dbname
	* postgres+ssl://user:password@host-or-ip:port/dbname
	* sqlite:///path/to/my.db
* `DATA_DIRECTORY` - Default `/data`. Path to SQL scripts.

### Volumes

* `/data` - where the tool look for SQL scripts


## Inside

* [Alpine Linux](https://www.alpinelinux.org/)
* SQL Runner Tool (written on Node.js)

## Launch for development purposes

```shell
SQL_SCRIPTS_PATH=/path/to/sql-scripts
DATABASE_URL=postgres://user:password@host-or-ip:port/dbname

docker run --rm --interactive --mount "type=bind,source=${SQL_SCRIPTS_PATH},target=/data" --env DATABASE_URL theanurin/sqlrunner
```
