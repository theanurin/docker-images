FROM alpine:3.15.0
RUN apk add --no-cache bash cryptsetup e2fsprogs nano
# Copy entrypoint script to root /
COPY --chown=root:root docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
VOLUME ["/data"]
ENTRYPOINT [ "/usr/local/bin/docker-entrypoint.sh" ]