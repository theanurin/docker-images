[![Docker Image Version](https://img.shields.io/docker/v/theanurin/pgadmin4?sort=date&label=Version)](https://hub.docker.com/r/theanurin/pgadmin4/tags)
[![Docker Image Size](https://img.shields.io/docker/image-size/theanurin/pgadmin4?label=Image%20Size)](https://hub.docker.com/r/theanurin/pgadmin4/tags)
[![Docker Pulls](https://img.shields.io/docker/pulls/theanurin/pgadmin4?label=Pulls)](https://hub.docker.com/r/theanurin/pgadmin4)
[![Docker Stars](https://img.shields.io/docker/stars/theanurin/pgadmin4?label=Docker%20Stars)](https://hub.docker.com/r/theanurin/pgadmin4)

# pgAdmin

[pgAdmin](https://www.pgadmin.org/) is the most popular and feature rich Open Source administration and development platform for PostgreSQL, the most advanced Open Source database in the world.

# Image reason

- Changed background color

# Spec

## Environment variables

- `PGADMIN_BG_COLOR` - this variable passes the name of the color to change background color

## Expose ports

- `tcp/80` - pgAdmin listening endpoint

## Volumes

- No any volumes

# Inside

* pgAdmin4 v8.5

# Launch

```shell
docker run --rm -it \
  --env PGADMIN_BG_COLOR='#000fff' \
  --env 'PGADMIN_DEFAULT_EMAIL=user@example.org' \
  --env 'PGADMIN_DEFAULT_PASSWORD=SuperSecret' \
  --publish 80:80 \
  theanurin/pgadmin4
```

# Support

- Maintained by: [Max Anurin](https://anurin.name/)
- Where to get help: [Telegram](https://t.me/theanurin)
