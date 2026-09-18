ARG IMAGE_TAG_UBUNTU=26.10

FROM ubuntu:${IMAGE_TAG_UBUNTU}
#ARG FLUTTER_REF=3.47.4
ARG FLUTTER_REF=master

# Install essential dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    yq \
    unzip \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash flutter \
    && mkdir -p /build /opt/flutter \
    && chown -R flutter:flutter /build /opt/flutter

COPY docker/docker-entrypoint.sh /usr/local/bin/docker-entrypoint-flutter.sh

USER flutter

# Clone the specific Flutter version you need (e.g., stable)
# Run doctor and pre-download the web artifacts
RUN \
  git clone --branch "${FLUTTER_REF}" --single-branch --depth 1 https://github.com/flutter/flutter.git /opt/flutter \
  && /opt/flutter/bin/flutter config --no-analytics \
  && /opt/flutter/bin/flutter doctor \
  && /opt/flutter/bin/flutter config --enable-web \
  && /opt/flutter/bin/flutter --version

ENV PATH="/opt/flutter/bin:${PATH}"

WORKDIR /build

ENTRYPOINT ["/usr/local/bin/docker-entrypoint-flutter.sh"]
