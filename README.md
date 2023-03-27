[![Docker Image Version](https://img.shields.io/docker/v/theanurin/fluentd?sort=date&label=Version)](https://hub.docker.com/r/theanurin/fluentd/tags)
[![Docker Image Size](https://img.shields.io/docker/image-size/theanurin/fluentd?label=Image%20Size)](https://hub.docker.com/r/theanurin/fluentd/tags)
[![Docker Pulls](https://img.shields.io/docker/pulls/theanurin/fluentd?label=Pulls)](https://hub.docker.com/r/theanurin/fluentd)
[![Docker Stars](https://img.shields.io/docker/stars/theanurin/fluentd?label=Docker%20Stars)](https://hub.docker.com/r/theanurin/fluentd)

# Fluentd

[Fluentd](https://www.fluentd.org/) is an open source data collector for unified logging layer.

# Image reason

This just our infrastructure image.

# Inside

| Item                                                                                            | Version  |
|-------------------------------------------------------------------------------------------------|----------|
| [Fluentd](https://www.fluentd.org/)                                                             | 1.16-1   |
| [fluent-plugin-elasticsearch](https://rubygems.org/gems/fluent-plugin-elasticsearch)            | 5.3.0    |
| [fluent-plugin-rewrite-tag-filter](https://rubygems.org/gems/fluent-plugin-rewrite-tag-filter)  | 2.4.0    |

# Launch

```shell
docker run --interactive --tty --rm theanurin/fluentd --dry-run
```


# Support

* Maintained by: [Max Anurin](https://anurin.name/)
* Where to get help: [Telegram](https://t.me/theanurin)
