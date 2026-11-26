FROM traefik:v2.11.64
ARG VER_PYTHON=3.14.10-r2
ARG VER_PYTHON_REQUESTS=2.33.1-r0
RUN apk add --no-cache \
    python3~=${VER_PYTHON} \
    py3-requests=~${VER_PYTHON_REQUESTS}
