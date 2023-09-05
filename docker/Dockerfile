ARG BUILD_IMAGE=ruby:3.2.2-alpine3.17

FROM ${BUILD_IMAGE} AS builder
ARG JEKYLL_GEM_VERSION=4.3.2
ARG JEMOJI_GEM_VERSION=0.13.0
ARG JUST_THE_DOCS_GEM_VERSION=0.6.1
ARG MINITEST_GEM_VERSION=5.19.0
ARG RACC_GEM_VERSION=1.7.1
ARG REXML_GEM_VERSION=3.2.6
RUN \
  test "$GEM_HOME" == '/usr/local/bundle' && \
  apk add --no-cache build-base gcompat libxml2 libxslt && \
  apk add --no-cache --virtual .build-deps libxml2-dev libxslt-dev && \
  gem install bundler && \
  gem install jekyll -v "${JEKYLL_GEM_VERSION}" && \
  gem install jemoji -v "${JEMOJI_GEM_VERSION}" && \
  gem install just-the-docs -v "${JUST_THE_DOCS_GEM_VERSION}" && \
  gem install minitest -v "${MINITEST_GEM_VERSION}" && \
  gem install racc -v "${RACC_GEM_VERSION}" && \
  gem install rexml -v "${REXML_GEM_VERSION}" && \
  rm -rf $GEM_HOME/cache && \
  apk del .build-deps
COPY docker/docker-entrypoint.sh /usr/local/bin/docker-entrypoint-jekyll.sh
VOLUME [ "/data", "/usr/local/bundle/cache" ]
EXPOSE 4000
ENTRYPOINT [ "/usr/local/bin/docker-entrypoint-jekyll.sh" ]
