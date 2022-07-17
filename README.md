[![Build Status](https://github.com/zxteamorg/docker.jekyll/actions/workflows/build.yml/badge.svg)](https://github.com/zxteamorg/docker.jekyll/actions/workflows/build.yml)
[![Docker Image Version](https://img.shields.io/docker/v/zxteamorg/jekyll?sort=date&label=Version)](https://hub.docker.com/r/zxteamorg/jekyll/tags)
[![Docker Image Size](https://img.shields.io/docker/image-size/zxteamorg/jekyll?label=Image%20Size)](https://hub.docker.com/r/zxteamorg/jekyll/tags)
[![Docker Pulls](https://img.shields.io/docker/pulls/zxteamorg/jekyll?label=Image%20Pulls)](https://hub.docker.com/r/zxteamorg/jekyll)
[![Docker Stars](https://img.shields.io/docker/stars/zxteamorg/jekyll?label=Image%20Stars)](https://hub.docker.com/r/zxteamorg/jekyll)

# Jekyll

[Jekyll](https://jekyllrb.com/) - Transform your plain text into static websites and blogs.

* Simple - No more databases, comment moderation, or pesky updates to install—just your content.
* Static - Markdown, Liquid, HTML & CSS go in. Static sites come out ready for deployment.
* Blog-aware - Permalinks, categories, pages, posts, and custom layouts are all first-class citizens here.
* Free hosting with GitHub Pages

# Image reason

1. The image embedding fixed version of `Jekyll` to prevent breaking changes in `Jekyll` and it's dependencies.
1. Official images do not support ARM64 arch such a Apple M1


# Spec

## Expose ports

* `tcp/4000` - `Jekyll` development server listening endpoint


## Volumes

* `/data` - Sources root (bind/mount here your work directory)


# Inside

* [Jekyll](https://jekyllrb.com/) v4.2.2
* [Bundler gem](https://rubygems.org/gems/bundler) v2.3.18
* [json gem](https://rubygems.org/gems/json) v2.6.2


# Launch
1. Start development server in site root directory (where `jekyll's _config.yml` located)
	```bash
	docker run --interactive --rm --volume ${PWD}:/data --publish 4000:4000 zxteamorg/jekyll
	```
1. Open browser http://127.0.0.1:4000/
1. Edit content and look for hot-reloaded changes in the browser


# Support

* Maintained by: [ZXTeam](https://zxteam.org)
* Where to get help: [Telegram Channel](https://t.me/zxteamorg)


# Development
## Build and debug
```shell
docker build --tag zxteamorg/jekyll --file Dockerfile . && docker run --interactive --tty --rm --entrypoint /bin/sh zxteamorg/jekyll
```