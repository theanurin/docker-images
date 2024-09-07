FROM node:12-alpine AS builder
WORKDIR /build/usr/local/bin/
RUN npm install --production --no-save @zxteam/cancellation @zxteam/configuration @zxteam/errors @zxteam/logger @zxteam/sql mustache
COPY docker/docker-entrypoint.js /build/usr/local/bin/docker-entrypoint.js

FROM node:12-alpine
ENV ENV=""
ENV DIST_PATH=".dist"
ENV EXTRA_CONFIGS=""
ENV SOURCE_PATH="migration"
ENV VERSION_FROM=""
ENV VERSION_TO=""
COPY --from=builder /build/ /
#VOLUME [ "/data" ]
WORKDIR /data
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.js"]
