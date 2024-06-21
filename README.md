[![GitHub Workflow Status][GitHub Workflow Status]][GitHub Workflow Log]
[![GitHub Repo Stars]][GitHub Repo Branch]
[![Docker Pulls][Docker Pulls]][Docker Repo]
[![Docker Stars][Docker Stars]][Docker Repo]

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

* [Jekyll](https://jekyllrb.com/) v4.3.3
* [Bundler gem](https://rubygems.org/gems/bundler)
* Additional Gems:
  * [jemoji](https://rubygems.org/gems/jemoji) v0.13.0
  * [just-the-docs](https://rubygems.org/gems/just-the-docs) v0.8.2
  * [minitest](https://rubygems.org/gems/minitest) v5.24.0
  * [racc](https://rubygems.org/gems/racc) v1.8.0
  * [rexml](https://rubygems.org/gems/rexml) v3.3.0
* [Git](https://git-scm.com/) v2.40.1
* [Git LFS](https://git-lfs.com/) v3.3.0
* [NodeJS](https://nodejs.org/) v18.20.1
* [NPM](https://www.npmjs.com/) v9.6.6
  * [Pug](https://www.npmjs.com/package/pug)

# Launch
1. Start development server in site root directory (where `jekyll's _config.yml` located)
  ```bash
  docker run --interactive --rm \
    --volume ${PWD}:/data \
    --publish 4000:4000 \
    theanurin/jekyll
  ```
1. Open browser http://127.0.0.1:4000/
1. Edit content and look for hot-reloaded changes in the browser


# Support

* Maintained by: [Max Anurin](https://anurin.name/)
* Where to get help: [Telegram](https://t.me/theanurin)


# Development

## Build and debug
```shell
docker build --tag theanurin/jekyll --file docker/Dockerfile . && \
  docker run --interactive --tty --rm --entrypoint /bin/sh theanurin/jekyll
```

[GitHub Repo Branch]: https://github.com/theanurin/docker-images/tree/jekyll
[GitHub Repo Stars]: https://img.shields.io/github/stars/theanurin/docker-images?label=GitHub%20Starts
[GitHub Workflow Status]: https://img.shields.io/github/actions/workflow/status/theanurin/docker-images/jekyll-docker-image-release.yml?label=GitHub%20Workflow
[GitHub Workflow Log]: https://github.com/theanurin/docker-images/actions/workflows/jekyll-docker-image-release.yml
[Docker Repo]: https://hub.docker.com/r/theanurin/jekyll
[Docker Tags]: https://hub.docker.com/r/theanurin/jekyll/tags
[Docker Stars]: https://img.shields.io/docker/stars/theanurin/jekyll?label=Docker%20Stars
[Docker Pulls]: https://img.shields.io/docker/pulls/theanurin/jekyll?label=Pulls
