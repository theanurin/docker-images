FROM rediscommander/redis-commander@sha256:19cd0c49f418779fa2822a0496c5e6516d0c792effc39ed20089e6268477e40a

USER root

RUN apk add --no-cache sudo
COPY docker/docker-entrypoint.sh /usr/local/bin/docker-entrypoint-redis-commander.sh

ENV REDIS_COMMANDER_BG_COLOR=
ENTRYPOINT ["/usr/local/bin/docker-entrypoint-redis-commander.sh"]