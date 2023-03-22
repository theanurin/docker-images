FROM alpine:3.11.3

RUN apk add --no-cache subversion=1.12.2-r1 sudo && \
	echo "Set disable_coredump false" > /etc/sudo.conf

COPY docker/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

EXPOSE 3690
WORKDIR /data
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

