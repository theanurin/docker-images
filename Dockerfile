ARG BUILD_IMAGE=alpine:3.12.0

FROM ${BUILD_IMAGE} AS Builder
ARG PROTOBUF_VERSION=3.13.0
WORKDIR /build
RUN apk add --no-cache gcc g++ make
RUN wget -qO- https://github.com/protocolbuffers/protobuf/releases/download/v${PROTOBUF_VERSION}/protobuf-all-${PROTOBUF_VERSION}.tar.gz | tar -xzp
RUN cd protobuf-${PROTOBUF_VERSION}/ && ./configure
RUN cd protobuf-${PROTOBUF_VERSION}/ && make -j$(nproc)
RUN cd protobuf-${PROTOBUF_VERSION}/ && make install
RUN rm /usr/local/lib/*.a /usr/local/lib/*.la
COPY ./docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN mkdir -p /build/root/usr && mv /usr/local /build/root/usr/

FROM ${BUILD_IMAGE}
COPY --from=Builder /build/root/ /
RUN apk add --no-cache nodejs npm && npm install --global google-protobuf typescript ts-protoc-gen && npm cache clean --force
ENV DATA_IN=/data/in
ENV DATA_OUT=/data/out
ENV VERBOSE=no
VOLUME [ "/data/in", "/data/out" ]
WORKDIR /
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
