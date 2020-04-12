ARG IMAGE=node:16-alpine

FROM ${IMAGE} AS Builder
WORKDIR /build
COPY bin ./usr/local/sqlmigrationrunner-postgres/migration/bin
COPY patches ./usr/local/sqlmigrationrunner-postgres/migration/patches
COPY package.json ./usr/local/sqlmigrationrunner-postgres/migration/
COPY package-lock.json ./usr/local/sqlmigrationrunner-postgres/migration/
RUN \
  cd ./usr/local/sqlmigrationrunner-postgres/migration/ \
  && npm install --no-progress --production \
  && rm -rf patches \
  && npm uninstall patch-package
COPY README.md ./usr/local/sqlmigrationrunner-postgres/migration/
COPY docker/docker-entrypoint.sh ./usr/local/bin/docker-entrypoint.sh

FROM ${IMAGE}
COPY --from=Builder /build /
WORKDIR /usr/local/sqlmigrationrunner-postgres/migration
ENV POSTGRES_URL=
ENV TARGET_VERSION=
VOLUME /etc/sqlmigrationrunner-postgres/migration/secrets /run/secrets /var/local/sqlmigrationrunner-postgres/migration
USER node
ENTRYPOINT [ "/usr/local/bin/docker-entrypoint.sh" ]
CMD [ "banner" ]
