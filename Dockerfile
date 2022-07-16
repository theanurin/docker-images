ARG BUILD_IMAGE=ruby:2.7.6-alpine3.16

FROM ${BUILD_IMAGE} AS builder
ARG JEKYLL_VERSION=4.2.2
ARG BUNDLER_VERSION=2.3.18
RUN \
 apk add --no-cache --virtual .build-deps gcc g++ make && \
 gem install jekyll -v "${JEKYLL_VERSION}" && \
 gem install bundler -v "${BUNDLER_VERSION}" && \
 apk del .build-deps
# RUN apk add --no-cache \
#   rust=${RUST_VERSION} \
#   cargo=${RUST_VERSION} \
#   git=${GIT_VERSION}
COPY docker-entrypoint.sh /usr/local/bin/zxteamorg-jekyll-docker-entrypoint.sh
VOLUME /data
EXPOSE 4000
ENTRYPOINT [ "/usr/local/bin/zxteamorg-jekyll-docker-entrypoint.sh" ]
