ARG IMAGE_TAG_UBUNTU=26.10

FROM ubuntu:${IMAGE_TAG_UBUNTU}
#ARG FLUTTER_REF=master
ARG FLUTTER_REF=3.47.5
ARG FLUTTER_RUST_BRIDGE_VER=2.13.0

ENV \
    RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH="/opt/flutter/bin:/usr/local/cargo/bin:$PATH"

# Install essential dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    yq \
    unzip \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash flutter \
    && mkdir -p /build /opt/flutter \
    && chown -R flutter:flutter /build /opt/flutter \
    && chmod -R a+w /usr/local

COPY docker/docker-entrypoint.sh /usr/local/bin/docker-entrypoint-flutter.sh

USER flutter

RUN echo \
  && curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

RUN echo \
  && rustup toolchain install nightly \
  && rustup +nightly component add rust-src \
  && rustup +nightly target add wasm32-unknown-unknown

RUN echo \
  && cargo install flutter_rust_bridge_codegen --version "${FLUTTER_RUST_BRIDGE_VER}"

# Clone the specific Flutter version you need (e.g., stable)
# Run doctor and pre-download the web artifacts
RUN echo \
  && git clone --branch "${FLUTTER_REF}" --single-branch --depth 1 https://github.com/flutter/flutter.git /opt/flutter \
  && /opt/flutter/bin/flutter config --no-analytics \
  && /opt/flutter/bin/flutter doctor \
  && /opt/flutter/bin/flutter config --enable-web \
  && /opt/flutter/bin/flutter --version

WORKDIR /build

ENTRYPOINT ["/usr/local/bin/docker-entrypoint-flutter.sh"]
