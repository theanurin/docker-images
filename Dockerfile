FROM node:12-alpine AS Builder
WORKDIR /build/usr/local/bin/
RUN npm install --production --no-save @zxteam/cancellation @zxteam/configuration @zxteam/errors @zxteam/logger @zxteam/sql mustache
COPY docker-entrypoint.js /build/usr/local/bin/docker-entrypoint.js

FROM node:12-alpine
ENV VERSION_FROM=""
ENV VERSION_TO=""
ENV ENV=""
ENV SOURCE_PATH="updates"
ENV BUILD_PATH=".dist"
ENV EXTRA_CONFIGS=""
COPY --from=Builder /build/ /
VOLUME [ "/data" ]
WORKDIR /data
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.js"]
