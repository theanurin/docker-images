ARG DEBIAN_BUILD=buster-slim
ARG RUST_BUILD=1.52-buster

FROM rust:${RUST_BUILD} AS builder
ARG TONOS_CLI_TAG_VERSION="0.13.0"
ARG VER_LIBSSDEV="1.1.1d-0+deb10u6"
ARG VER_PKGCONFIG="0.29-6"
WORKDIR /build

# Get sources
RUN wget -qO- "https://github.com/tonlabs/tonos-cli/archive/refs/tags/v${TONOS_CLI_TAG_VERSION}.tar.gz" | tar -xz

# Setup build environment
RUN apt-get update && \
  apt-get install -y \
    "libssl-dev=${VER_LIBSSDEV}" \
    "pkg-config=${VER_PKGCONFIG}" && \
  rm -rf /var/lib/apt/lists/*

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

# Create "tonos" user
RUN useradd --create-home --user-group --home-dir /data tonos \
&& mkdir -p /build/stage/etc \
&& cp /etc/group /etc/passwd /etc/shadow /build/stage/etc/

COPY docker-entrypoint.sh /build/stage/usr/local/bin/
RUN chmod +x /build/stage/usr/local/bin/docker-entrypoint.sh


# Final image
FROM debian:${DEBIAN_BUILD}
LABEL maintainer="ZXTeam <devel@zxteam.org>"
ARG VER_OPENSSL="1.1.1d-0+deb10u6"
ARG VER_CACERTIFICATES="20200601~deb10u2"
RUN apt-get update && \
  apt-get install -y \
      "openssl=${VER_OPENSSL}" \
      "ca-certificates=${VER_CACERTIFICATES}" && \
  rm -rf /var/lib/apt/lists/*
COPY --from=builder /build/stage/ /
VOLUME /data
WORKDIR /data
ENV TONOSCLI_CONFIG=/data/tonos-cli.conf.json
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["--help"]
