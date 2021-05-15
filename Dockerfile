ARG BUILD_IMAGE=alpine:3.13.5

FROM ${BUILD_IMAGE} AS postgres_builder
RUN apk add --no-cache postgresql postgresql-contrib
RUN apk add --no-cache bash
COPY docker-build.sql /build-toolkit/
COPY docker-build.sh /build-toolkit/
RUN chmod +x /build-toolkit/docker-build.sh && /build-toolkit/docker-build.sh
COPY docker-entrypoint.sh /build/usr/local/bin/
RUN chmod +x /build/usr/local/bin/docker-entrypoint.sh

FROM ${BUILD_IMAGE}
RUN apk add --no-cache postgresql postgresql-contrib
COPY --from=postgres_builder /build/ /
USER root
VOLUME /data
EXPOSE 5432
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
