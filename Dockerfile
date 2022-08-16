FROM alpine:3.15.0
LABEL "org.opencontainers.image.title"="Luksoid"
LABEL "org.opencontainers.image.description"="Luksoid - is a Docker-based command line tool to help users to use LUKS-encrypted partition image without Linux host."
LABEL "org.opencontainers.image.source"="https://github.com/theanurin/docker-images/tree/luksoid"
RUN apk add --no-cache bash cryptsetup e2fsprogs nano
# Copy entrypoint script to root /
COPY --chown=root:root docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
VOLUME ["/data"]
ENTRYPOINT [ "/usr/local/bin/docker-entrypoint.sh" ]
