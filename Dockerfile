ARG BUILD_IMAGE=debian:stretch-slim

FROM ${BUILD_IMAGE} AS builder
LABEL maintainer="ZXTeam <devel@zxteam.org>"
ARG LITECOIN_CORE_TAG_VERSION="0.18.1"
WORKDIR /build

# Build environment
RUN apt-get update && apt-get install -y \
  wget \
  build-essential=12.3 \
  libtool=2.4.6-2 \
  autotools-dev=20161112.1 \
  automake=1:1.15-6 \
  pkg-config=0.29-4+b1 \
  bsdmainutils=9.0.12+nmu1 \
  python3=3.5.3-1 \
  libssl-dev=1.1.0l-1~deb9u3 \
  libevent-dev=2.0.21-stable-3 \
  libboost-system-dev=1.62.0.1 \
  libboost-filesystem-dev=1.62.0.1 \
  libboost-chrono-dev=1.62.0.1 \
  libboost-test-dev=1.62.0.1 \
  libboost-thread-dev=1.62.0.1

# Get sources
RUN wget -qO- "https://github.com/litecoin-project/litecoin/archive/refs/tags/v${LITECOIN_CORE_TAG_VERSION}.tar.gz" | tar -xz

# Build
WORKDIR "/build/litecoin-${LITECOIN_CORE_TAG_VERSION}"

# Prepare build toolkit
RUN ./autogen.sh

# Build Berkeley DB 4.8 due Debian image has incompatible 5.1 or later version (See https://github.com/litecoin-project/litecoin/blob/81c4f2d80fbd33d127ff9b31bf588e4925599d79/doc/build-unix.md#dependency-build-instructions)
RUN ./contrib/install_db4.sh `pwd`

# Configure with low memory usage to be able to autobuild on Docker Hub (See https://docs.docker.com/docker-hub/builds/ and https://github.com/litecoin-project/litecoin/blob/81c4f2d80fbd33d127ff9b31bf588e4925599d79/doc/build-unix.md#memory-requirements)
RUN ./configure \
#  CXXFLAGS="--param ggc-min-expand=1 --param ggc-min-heapsize=32768" \
  BDB_LIBS="-L/build/litecoin-${LITECOIN_CORE_TAG_VERSION}/db4/lib -ldb_cxx-4.8" \
  BDB_CFLAGS="-I/build/litecoin-${LITECOIN_CORE_TAG_VERSION}/db4/include" \
  --without-gui

# Make binaries
RUN make

# Install binaries into /usr/local/bin
RUN make install

# Stage binaries
RUN mkdir -p /build/stage/usr/local/bin \
&& cd /usr/local/bin \
&& mv litecoin-cli litecoin-tx litecoin-wallet litecoind /build/stage/usr/local/bin

# Create "data" user
RUN useradd --create-home --user-group --home-dir /data data \
  && mkdir -p /build/stage/etc \
  && cp /etc/group /etc/passwd /etc/shadow /build/stage/etc/

COPY docker-entrypoint.sh /build/stage/usr/local/bin/
RUN chmod +x /build/stage/usr/local/bin/docker-entrypoint.sh


# Final image
FROM ${BUILD_IMAGE}
LABEL maintainer="ZXTeam <devel@zxteam.org>"
COPY --from=builder /build/stage/ /
RUN apt-get update && apt-get install -y libboost-chrono1.62.0 libboost-thread1.62.0 libevent-2.0-5 libevent-pthreads-2.0-5 libssl1.0.2 openssl && rm -rf /var/lib/apt/lists/*
VOLUME /data
EXPOSE 9332 9333 19332 19335 19443 19444
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["-printtoconsole", "-datadir=/data", "-port=9333", "-rpcbind=0.0.0.0:9332", "-rpcallowip=0.0.0.0/0", "-disablewallet"]
