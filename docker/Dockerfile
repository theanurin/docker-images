ARG BUILD_IMAGE=ruby:3.3.7-alpine3.20

FROM ${BUILD_IMAGE} AS builder
ARG JEKYLL_GEM_VERSION=4.3.4
ARG JEMOJI_GEM_VERSION=0.13.0
ARG JUST_THE_DOCS_GEM_VERSION=0.10.1
ARG MINITEST_GEM_VERSION=5.25.4
ARG NODEJS_VERSION=20.15.1-r0
ARG NPM_VERSION=10.9.1-r0
ARG PUG_VERION=3.0.3
ARG GIT_VERSION=2.45.3-r0
ARG GITLFS_VERSION=3.5.1-r4
ARG RACC_GEM_VERSION=1.8.1
ARG REXML_GEM_VERSION=3.4.0
RUN \
  test "${GEM_HOME}" == '/usr/local/bundle' && \
  apk add --no-cache build-base gcompat libxml2 libxslt linux-headers && \
  apk add --no-cache nodejs~="${NODEJS_VERSION}" && \
  apk add --no-cache npm~="${NPM_VERSION}" && \
  npm install --global "pug@${PUG_VERION}" && \
  apk add --no-cache libxml2-dev libxslt-dev && \
  apk add --no-cache git~="${GIT_VERSION}" && \
  apk add --no-cache git-lfs~="${GITLFS_VERSION}" && \
  gem install bundler && \
  gem install jekyll -v "${JEKYLL_GEM_VERSION}" && \
  gem install jemoji -v "${JEMOJI_GEM_VERSION}" && \
  gem install just-the-docs -v "${JUST_THE_DOCS_GEM_VERSION}" && \
  gem install minitest -v "${MINITEST_GEM_VERSION}" && \
  gem install racc -v "${RACC_GEM_VERSION}" && \
  gem install rexml -v "${REXML_GEM_VERSION}" && \
  rm -rf "${GEM_HOME}/cache"
COPY docker/docker-entrypoint.sh /usr/local/bin/docker-entrypoint-jekyll.sh
EXPOSE 4000 4001
ENTRYPOINT [ "/usr/local/bin/docker-entrypoint-jekyll.sh" ]
