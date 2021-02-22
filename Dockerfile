ARG BUILD_IMAGE=debian:stretch-slim

FROM ${BUILD_IMAGE} AS builder
LABEL maintainer="ZXTeam <devel@zxteam.org>"
ARG ZCLASSIC_TAG_VERSION="2.1.1-2"
WORKDIR /build

# Build environment
RUN apt-get update && apt-get install -y build-essential pkg-config libc6-dev m4 g++-multilib autoconf libtool ncurses-dev unzip git python python-zmq zlib1g-dev wget curl bsdmainutils automake pwgen && rm -rf /var/lib/apt/lists/*

# Get sources
RUN wget -qO- "https://github.com/ZclassicCommunity/zclassic/archive/v${ZCLASSIC_TAG_VERSION}.tar.gz" | tar -xz

# Build
RUN cd "zclassic-${ZCLASSIC_TAG_VERSION}" && ./zcutil/build.sh

# Stage binaries
RUN mkdir -p /build/stage/usr/bin \
&& cd "zclassic-${ZCLASSIC_TAG_VERSION}" \
&& mv src/zclassic-cli src/zclassic-tx src/zclassicd zcutil/fetch-params.sh /build/stage/usr/bin/

# Create "data" user
RUN useradd --create-home --user-group --home-dir /data data \
&& mkdir -p /build/stage/etc \
&& cp /etc/group /etc/passwd /etc/shadow /build/stage/etc/

COPY docker-entrypoint.sh /build/stage/usr/local/bin/
RUN chmod +x /build/stage/usr/local/bin/docker-entrypoint.sh


# Final image
FROM ${BUILD_IMAGE}
LABEL maintainer="ZXTeam <devel@zxteam.org>"
RUN apt-get update && apt-get install -y libgomp1 pwgen wget && rm -rf /var/lib/apt/lists/*
COPY --from=builder /build/stage/ /
VOLUME /data/.zcash-params
VOLUME /data/.zclassic
EXPOSE 8033 8023
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["-printtoconsole", "-port=8033", "-rpcbind=0.0.0.0:8023", "-rpcallowip=0.0.0.0/0"]
