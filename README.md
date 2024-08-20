[![Docker Image Version](https://img.shields.io/docker/v/theanurin/traefik?sort=date&label=Version)](https://hub.docker.com/r/theanurin/traefik/tags)
[![Docker Image Size](https://img.shields.io/docker/image-size/theanurin/traefik?label=Image%20Size)](https://hub.docker.com/r/theanurin/traefik/tags)
[![Docker Pulls](https://img.shields.io/docker/pulls/theanurin/traefik?label=Pulls)](https://hub.docker.com/r/theanurin/traefik)
[![Docker Stars](https://img.shields.io/docker/stars/theanurin/traefik?label=Docker%20Stars)](https://hub.docker.com/r/theanurin/traefik)

# Traefik

[Traefik](https://github.com/traefik/traefik) (pronounced traffic) is a modern HTTP reverse proxy and load balancer that makes deploying microservices easy.

# Image reason

- Changed background color (to colorize your deployment zones)
- Include Python3 + [Requests](https://requests.readthedocs.io/en/latest/) library (to execute Python scripts to solve ACME DNS challenges)

# Spec

## Environment variables

This variables passes the names of the color to change background color

- `BG_COLOR`

## Volumes

- `/traefik-data`

# Inside

- Traefik v2.11.8
- Python 3.12.3-r1
- py3-requests 2.32.3-r0

# Launch

```shell
docker run --rm --interactive --tty \
  --env BG_COLOR='#ff0000' \
  --publish 80:80 \
  --publish 443:443 \
  --volume /var/run/docker.sock:/var/run/docker.sock \
  theanurin/traefik
```

# Support

* Maintained by: [Max Anurin](https://anurin.name/)
* Where to get help: [Telegram](https://t.me/theanurin)
