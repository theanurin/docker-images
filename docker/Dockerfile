ARG BUILD_IMAGE=ruby:3.2.3-alpine3.18

FROM ${BUILD_IMAGE} AS builder
ARG JEKYLL_GEM_VERSION=4.3.3
ARG JEMOJI_GEM_VERSION=0.13.0
ARG JUST_THE_DOCS_GEM_VERSION=0.7.0
ARG MINITEST_GEM_VERSION=5.21.2
ARG NODEJS_VERSION=18.18.2
ARG NPM_VERSION=9.6.6
ARG PUG_VERION=3.0.0
ARG RACC_GEM_VERSION=1.7.3
ARG REXML_GEM_VERSION=3.2.6
RUN \
  test "${GEM_HOME}" == '/usr/local/bundle' && \
  apk add --no-cache build-base gcompat libxml2 libxslt nodejs~="${NODEJS_VERSION}" npm~="${NPM_VERSION}" && \
  npm install --global "pug@${PUG_VERION}" && \
  apk add --no-cache libxml2-dev libxslt-dev && \
  gem install bundler && \
  gem install jekyll -v "${JEKYLL_GEM_VERSION}" && \
  gem install jemoji -v "${JEMOJI_GEM_VERSION}" && \
  gem install just-the-docs -v "${JUST_THE_DOCS_GEM_VERSION}" && \
  gem install minitest -v "${MINITEST_GEM_VERSION}" && \
  gem install racc -v "${RACC_GEM_VERSION}" && \
  gem install rexml -v "${REXML_GEM_VERSION}" && \
  rm -rf "${GEM_HOME}/cache"
COPY docker/docker-entrypoint.sh /usr/local/bin/docker-entrypoint-jekyll.sh
VOLUME [ "/data" ]
# ENV BUNDLE_PATH=/data/vendor/bundle
EXPOSE 4000
ENTRYPOINT [ "/usr/local/bin/docker-entrypoint-jekyll.sh" ]
