ARG BUILD_IMAGE=alpine:3.16.7


FROM ${BUILD_IMAGE} AS postgres_builder
ARG POSTGRES_PAKCAGE_VERSION=13.12-r0
RUN apk add --no-cache postgresql13=${POSTGRES_PAKCAGE_VERSION} postgresql13-contrib=${POSTGRES_PAKCAGE_VERSION}
RUN apk add --no-cache bash
COPY docker/docker-build.sql /build-toolkit/
COPY docker/docker-build.sh /build-toolkit/
RUN chmod +x /build-toolkit/docker-build.sh && /build-toolkit/docker-build.sh
COPY docker/docker-entrypoint.sh /build/usr/local/bin/docker-entrypoint-postgres-13.sh
RUN chmod +x /build/usr/local/bin/docker-entrypoint-postgres-13.sh

FROM ${BUILD_IMAGE}
ARG POSTGRES_PAKCAGE_VERSION=13.12-r0
RUN apk add --no-cache postgresql13=${POSTGRES_PAKCAGE_VERSION} postgresql13-contrib=${POSTGRES_PAKCAGE_VERSION}
COPY --from=postgres_builder /build/ /
USER root
#
# Volume /data make more problems than benefits...
# For some case we want to embed data in /data, but this is not possible due volume directive.
#
# https://stackoverflow.com/questions/44020785/remove-a-volume-in-a-dockerfile
# https://stackoverflow.com/questions/40006278/prevent-volume-creation-on-docker-run
#
# Comment it temporary while 
#VOLUME /data
EXPOSE 5432
ENTRYPOINT ["/usr/local/bin/docker-entrypoint-postgres-13.sh"]
