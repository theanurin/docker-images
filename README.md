[![Docker Image Version][Docker Image Version]][Docker Tags]
[![GitHub Workflow Status][GitHub Workflow Status]][GitHub Workflow Log]
[![GitHub Repo Stars]][GitHub Repo Branch]
[![Docker Pulls][Docker Pulls]][Docker Repo]
[![Docker Stars][Docker Stars]][Docker Repo]

# Flutter

Flutter SDK for build your web target projects

## Image reason

* no such official image
* use in build jobs

## Spec

### Environment variables

No any variables

### Expose ports

No any ports
 
### Volumes

No any volumes

## Inside

* [Ubuntu Linux](https://ubuntu.com/)
* [Flutter SDK](https://docs.flutter.dev/install/manual)

## Launch

```shell
alias flutter='docker run --rm --interactive --tty --mount "type=bind,source=$PWD,target=/build" theanurin/flutter'

flutter --version
flutter build web
```

# Support

* Maintained by: [Max Anurin](https://anurin.name/)
* Where to get help: [Telegram](https://t.me/theanurin)

# Development

## Build and debug

```shell
docker build --tag theanurin/flutter --file docker/Dockerfile . && \
  docker run --interactive --tty --rm  theanurin/flutter --version
```

[GitHub Repo Branch]: https://github.com/theanurin/docker-images/tree/flutter
[GitHub Repo Stars]: https://img.shields.io/github/stars/theanurin/docker-images?label=GitHub%20Starts
[GitHub Workflow Status]: https://img.shields.io/github/actions/workflow/status/theanurin/docker-images/flutter-docker-image-release.yml?label=GitHub%20Workflow
[GitHub Workflow Log]: https://github.com/theanurin/docker-images/actions/workflows/flutter-docker-image-release.yml
[Docker Repo]: https://hub.docker.com/r/theanurin/flutter
[Docker Tags]: https://hub.docker.com/r/theanurin/flutter/tags
[Docker Image Version]: https://img.shields.io/docker/v/theanurin/flutter?sort=date&label=Version
[Docker Stars]: https://img.shields.io/docker/stars/theanurin/flutter?label=Docker%20Stars
[Docker Pulls]: https://img.shields.io/docker/pulls/theanurin/flutter?label=Pulls
