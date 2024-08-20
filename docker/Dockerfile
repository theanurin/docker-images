FROM traefik:v2.2.0
ARG VER_PYTHON=3.8.10-r0
ARG VER_PYTHON_REQUESTS=2.22.0-r0
RUN apk add --no-cache \
    python3~=${VER_PYTHON} \
    py3-requests=~${VER_PYTHON_REQUESTS}
