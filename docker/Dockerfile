ARG PGADMIN4_VERSION=7.7

FROM dpage/pgadmin4:${PGADMIN4_VERSION}

USER root

RUN apk add --no-cache sudo

ENV PGADMIN_BG_COLOR=

COPY docker/docker-entrypoint.sh /usr/local/bin/docker-entrypoint-pgadmin4.sh

ENTRYPOINT ["/usr/local/bin/docker-entrypoint-pgadmin4.sh"]