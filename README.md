[![Docker Image Version](https://img.shields.io/docker/v/theanurin/redis-commander?sort=date&label=Version)](https://hub.docker.com/r/theanurin/redis-commander/tags)
[![Docker Image Size](https://img.shields.io/docker/image-size/theanurin/redis-commander?label=Image%20Size)](https://hub.docker.com/r/theanurin/redis-commander/tags)
[![Docker Pulls](https://img.shields.io/docker/pulls/theanurin/redis-commander?label=Pulls)](https://hub.docker.com/r/theanurin/redis-commander)
[![Docker Stars](https://img.shields.io/docker/stars/theanurin/redis-commander?label=Docker%20Stars)](https://hub.docker.com/r/theanurin/redis-commander)

# Redis Commander

Redis web management tool written in node.js

# Image reason

This is an image of Redis Commander with an additional option that allows you to set the color of the web interface when starting the container

# Spec

## Environment variables

REDIS_COMMANDER_BG_COLOR - Set background color for web interface Redis Commander (inject color into `css/default.css`)

## Expose ports

* `tcp/8081` - Redis Commander listening endpoint

## Volumes

* No any volumes

# Inside

* Redis Commander 0.7.2-rc3

# Launch

```shell
docker run --rm -it --env REDIS_COMMANDER_BG_COLOR=#ffffff \
--publish 39000:8081 theanurin/redis-commander
```

# Support

* Maintained by: [Max Anurin](https://anurin.name/)
* Where to get help: [Telegram](https://t.me/theanurin)
