FROM traefik:v3.3.1
ARG VER_PYTHON=3.12.8-r1
ARG VER_PYTHON_REQUESTS=2.32.3-r0
RUN apk add --no-cache \
    python3~=${VER_PYTHON} \
    py3-requests=~${VER_PYTHON_REQUESTS}
