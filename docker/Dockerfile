ARG ALPINE_VERSION=3.18.2

FROM alpine:${ALPINE_VERSION}
ARG SUBVERSION_PACKAGE_VERSION=1.14.2-r10
RUN apk add --no-cache subversion=${SUBVERSION_PACKAGE_VERSION} sudo && \
	echo "Set disable_coredump false" > /etc/sudo.conf

COPY docker/docker-entrypoint.sh /usr/local/bin/docker-entrypoint-subversion.sh

EXPOSE 3690
WORKDIR /data
ENTRYPOINT ["/usr/local/bin/docker-entrypoint-subversion.sh"]

