ARG BUILD_IMAGE=ruby:2.7.6-alpine3.16

FROM ${BUILD_IMAGE} AS builder
ARG JEKYLL_GEM_VERSION=4.2.2
ARG BUNDLER_GEM_VERSION=2.3.18
ARG JSON_GEM_VERSION=2.6.2
RUN \
 apk add --no-cache --virtual .build-deps gcc g++ make && \
 gem install jekyll -v "${JEKYLL_GEM_VERSION}" && \
 gem install bundler -v "${BUNDLER_GEM_VERSION}" && \
 gem install json -v "${JSON_GEM_VERSION}" && \
 apk del .build-deps
COPY docker-entrypoint.sh /usr/local/bin/zxteamorg-jekyll-docker-entrypoint.sh
VOLUME /data
EXPOSE 4000
ENTRYPOINT [ "/usr/local/bin/zxteamorg-jekyll-docker-entrypoint.sh" ]
