[![Docker Build Status](https://img.shields.io/docker/build/zxteamorg/devel.mkdocs?label=Status)](https://hub.docker.com/r/zxteamorg/devel.mkdocs/builds)
[![Docker Image Size (latest by date)](https://img.shields.io/docker/image-size/zxteamorg/devel.mkdocs?label=Size)](https://hub.docker.com/r/zxteamorg/devel.mkdocs/tags)
[![Docker Pulls](https://img.shields.io/docker/pulls/zxteamorg/devel.mkdocs?label=Pulls)](https://hub.docker.com/r/zxteamorg/devel.mkdocs)
[![Docker Image Version (latest by date)](https://img.shields.io/docker/v/zxteamorg/devel.mkdocs?sort=semver&label=Version)](https://hub.docker.com/r/zxteamorg/devel.mkdocs/tags)
[![Docker Image Info](https://images.microbadger.com/badges/image/zxteamorg/devel.mkdocs.svg)](https://hub.docker.com/r/zxteamorg/devel.mkdocs/dockerfile)

# MkDocs
[MkDocs](https://www.mkdocs.org/) is a fast, simple and downright gorgeous static site generator that's geared towards building project documentation. Documentation source files are written in Markdown, and configured with a single YAML configuration file. Start by reading the introduction below, then check the User Guide for more info.

# Image reason
The image embedding fixed version of MkDocs. Prevent breaking changes in MkDocs and it's dependencies. Our team has repeatedly encountered problems regards to breaking changes in MkDocs dependencies.

## Develop documentation
1. Start development server in documentation root directory (where `mkdocs.yml` located)
	```bash
	docker run --interactive --tty --rm --volume ${PWD}:/development --publish 8000:8000 zxteamorg/devel.mkdocs
	```
1. Open browser http://127.0.0.1:8000/
1. Edit content and look for hot-reloaded changes in the browser
