[![Docker Build Status](https://img.shields.io/docker/cloud/build/zxteamorg/devel.mkdocs?label=Build%20Status)](https://hub.docker.com/r/zxteamorg/devel.mkdocs/builds)
[![Docker Image Version](https://img.shields.io/docker/v/zxteamorg/devel.mkdocs?sort=date&label=Version)](https://hub.docker.com/r/zxteamorg/devel.mkdocs/tags)
[![Docker Image Size](https://img.shields.io/docker/image-size/zxteamorg/devel.mkdocs?label=Image%20Size)](https://hub.docker.com/r/zxteamorg/devel.mkdocs/tags)
[![Docker Pulls](https://img.shields.io/docker/pulls/zxteamorg/devel.mkdocs?label=Pulls)](https://hub.docker.com/r/zxteamorg/devel.mkdocs)
[![Docker Pulls](https://img.shields.io/docker/stars/zxteamorg/devel.mkdocs?label=Docker%20Stars)](https://hub.docker.com/r/zxteamorg/devel.mkdocs)
[![Docker Automation](https://img.shields.io/docker/cloud/automated/zxteamorg/devel.mkdocs?label=Docker%20Automation)](https://hub.docker.com/r/zxteamorg/devel.mkdocs/builds)

# MkDocs

[MkDocs](https://www.mkdocs.org/) is a fast, simple and downright gorgeous static site generator that's geared towards building project documentation. Documentation source files are written in Markdown, and configured with a single YAML configuration file.

# Image reason

The image embedding fixed version of MkDocs to prevent breaking changes in MkDocs and it's dependencies. Our team has repeatedly encountered problems regards to breaking changes in MkDocs dependencies.

# Spec

## Environment variables

* PYTHONPATH - Set path for additional Python's packages. Default /data/site-packages. (You may develop own extensions along with your site sources)

## Expose ports

* `tcp/8000` - MkDocs' development server listening endpoint

## Volumes

* `/data` - Sources root (bind/mount here your work direcory)

# Inside

* mkdocs==1.1.2
* mkdocs-material==5.5.12
* mkdocs-markdownextradata-plugin==0.1.7
* fontawesome_markdown==0.2.6

# Launch
1. Start development server in documentation root directory (where `mkdocs.yml` located)
	```bash
	docker run --interactive --tty --rm --volume ${PWD}:/data --publish 8000:8000 zxteamorg/devel.mkdocs
	```
1. Open browser http://127.0.0.1:8000/
1. Edit content and look for hot-reloaded changes in the browser

# Support

* Maintained by: [ZXTeam](https://zxteam.org)
* Where to get help: [Telegram Channel](https://t.me/zxteamorg)