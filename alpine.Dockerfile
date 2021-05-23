ARG ALPINE_BUILD=3.13.5
ARG RUST_BUILD=1.52-alpine3.13

FROM rust:${RUST_BUILD} AS builder
ARG TONOS_CLI_TAG_VERSION="0.13.0"
ARG VER_MUSLDEV="1.2.2-r0"
ARG VER_OPENSSLDEV="1.1.1k-r0"
ARG VER_PATCH="2.7.6-r6"
WORKDIR /build

# Get sources
RUN wget -qO- "https://github.com/tonlabs/tonos-cli/archive/refs/tags/v${TONOS_CLI_TAG_VERSION}.tar.gz" | tar -xz

# Setup build environment
RUN apk add --no-cache \
  "musl-dev=${VER_MUSLDEV}" \
  "openssl-dev=${VER_OPENSSLDEV}" \
  "patch=${VER_PATCH}" \
  nano

# Apply patch. See an issue https://github.com/tonlabs/tonos-cli/issues/166
COPY ./patches/v0.13.0-Cargo.lock.patch "./tonos-cli-${TONOS_CLI_TAG_VERSION}/patches/v0.13.0-Cargo.lock.patch"
RUN cd "tonos-cli-${TONOS_CLI_TAG_VERSION}" && \
  patch -i patches/v0.13.0-Cargo.lock.patch

# Build
RUN cd "tonos-cli-${TONOS_CLI_TAG_VERSION}" && \
  cargo build --release

# Stage binaries
RUN mkdir -p /build/stage/usr/local/bin && \
  cp "tonos-cli-${TONOS_CLI_TAG_VERSION}/target/release/tonos-cli" /build/stage/usr/local/bin/

# # Testing
# RUN cd "tonos-cli-${TONOS_CLI_TAG_VERSION}" && \
#   cargo test -- --test-threads 1

# Create "data" user
RUN addgroup -S tonos && adduser -S tonos -G tonos -s /bin/ash -H -h /data && \
  mkdir -p /build/stage/etc && \
  cp /etc/group /etc/passwd /etc/shadow /build/stage/etc/

COPY docker-entrypoint.sh /build/stage/usr/local/bin/
RUN chmod +x /build/stage/usr/local/bin/docker-entrypoint.sh


# Final image
FROM alpine:${ALPINE_BUILD}
LABEL maintainer="ZXTeam <devel@zxteam.org>"
ARG VER_OPENSSL="1.1.1k-r0"
ARG VER_CACERTIFICATES="20191127-r5"
RUN apk add --no-cache \
  "openssl=${VER_OPENSSL}" \
  "ca-certificates=${VER_CACERTIFICATES}"
#RUN apk add --no-cache strace
COPY --from=builder /build/stage/ /
VOLUME /data
WORKDIR /data
ENV TONOSCLI_CONFIG=/data/tonos-cli.conf.json
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["--help"]
