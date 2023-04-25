ARG BUILD_IMAGE=ruby:2.7.6-alpine3.16
#ARG BUILD_IMAGE=ruby:3.0-alpine

FROM ${BUILD_IMAGE} AS builder
ARG JEKYLL_GEM_VERSION=4.2.2
RUN \
 apk add --no-cache gcompat libxml2 libxslt && \
 apk add --no-cache --virtual .build-deps build-base libxml2-dev libxslt-dev && \
 gem install bundler && \
 gem install jekyll -v "${JEKYLL_GEM_VERSION}" && \
 gem install json && \
 gem install nokogiri --platform=ruby -- --use-system-libraries && \
 gem install racc && \
 rm -rf $GEM_HOME/cache && \
 apk del .build-deps
COPY docker/docker-entrypoint.sh /usr/local/bin/docker-entrypoint-jekyll.sh
VOLUME /data
EXPOSE 4000
ENTRYPOINT [ "/usr/local/bin/docker-entrypoint-jekyll.sh" ]
