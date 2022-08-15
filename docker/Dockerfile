ARG IMAGE=node:18-alpine

FROM ${IMAGE} AS builder
COPY bin /build/usr/local/sqlrunner/bin
COPY package.json /build/usr/local/sqlrunner/
COPY package-lock.json /build/usr/local/sqlrunner/
COPY README.md /build/usr/local/sqlrunner/
RUN cd /build/usr/local/sqlrunner/ && npm install --no-progress --production
COPY docker/docker-entrypoint.sh /build/usr/local/bin/sqlrunner-docker-entrypoint.sh

FROM ${IMAGE}
COPY --from=builder /build /
ENV DATA_DIRECTORY="/data"
USER node
ENTRYPOINT [ "/usr/local/bin/sqlrunner-docker-entrypoint.sh" ]
CMD []
