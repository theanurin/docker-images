ARG PORTAINER_VERSION=2.20.1-alpine
ARG ALPINE_VERSION=3.19.1

FROM portainer/portainer-ce:${PORTAINER_VERSION} AS portainer

FROM alpine:${ALPINE_VERSION}
COPY --from=portainer / /
COPY docker/docker-entrypoint.sh /usr/local/bin/docker-entrypoint-portainer.sh
ENV PORTAINER_LIGHT_BG_COLOR=
ENV PORTAINER_DARK_BG_COLOR=
ENV PORTAINER_HIGH_BG_COLOR=
ENTRYPOINT ["/usr/local/bin/docker-entrypoint-portainer.sh"]
