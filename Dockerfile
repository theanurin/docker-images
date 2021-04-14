ARG BUILD_IMAGE=debian:stretch-slim

FROM ${BUILD_IMAGE} AS builder
LABEL maintainer="ZXTeam <devel@zxteam.org>"
ARG ZCLASSIC_TAG_VERSION="2.1.1-3"
WORKDIR /build

# Build environment
RUN apt-get update && apt-get install -y \
  wget curl \
  automake=1:1.15-6 \
  build-essential=12.3 \
  bsdmainutils=9.0.12+nmu1 \
  pkg-config=0.29-4+b1 \
  libc6-dev=2.24-11+deb9u4 \
  libtool=2.4.6-2 \
  m4=1.4.18-1 \
  g++-multilib=4:6.3.0-4 \
  autoconf=2.69-10 \
  libncurses5-dev=6.0+20161126-1+deb9u2 \
  unzip=6.0-21+deb9u2 \
  git=1:2.11.0-3+deb9u7 \
  python-zmq=16.0.2-2 \
  zlib1g-dev=1:1.2.8.dfsg-5 \
  pwgen=2.07-1.1+b1

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
