FROM node:22-alpine AS builder
WORKDIR /build/usr/local/bin/
RUN npm install --omit=dev --no-save @freemework/common@0.15.1 @freemework/hosting@0.15.1 mustache
COPY docker/docker-entrypoint.js /build/usr/local/bin/docker-entrypoint.js
COPY docker/log4js.json /build/usr/local/bin/log4js.json

FROM node:22-alpine
COPY --from=builder /build/ /
WORKDIR /data
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.js"]
CMD ["--config-env"]
