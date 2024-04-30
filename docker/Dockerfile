ARG ARCH=amd64
ARG IMAGE=node:20-alpine

FROM --platform=${ARCH} ${IMAGE} AS builder
WORKDIR /build
COPY bin ./usr/local/sqlmigration/bin
COPY .npmrc ./usr/local/sqlmigration/
COPY package.json ./usr/local/sqlmigration/
COPY package-lock.json ./usr/local/sqlmigration/
RUN cd ./usr/local/sqlmigration/ && npm install --no-progress --omit=dev && rm .npmrc
# Generate README.md
COPY README.md /tmp/
RUN echo > ./usr/local/sqlmigration/README.md 
RUN echo "-------------------------------------------------------------------------------------" >> ./usr/local/sqlmigration/README.md 
RUN echo "    Following a content of README.md. See more details inside sources repository.    " >> ./usr/local/sqlmigration/README.md 
RUN echo "-------------------------------------------------------------------------------------" >> ./usr/local/sqlmigration/README.md 
RUN echo >> ./usr/local/sqlmigration/README.md 
RUN cat /tmp/README.md >> ./usr/local/sqlmigration/README.md
# Entrypoint script
COPY docker/docker-entrypoint.sh ./usr/local/bin/docker-entrypoint.sh

FROM --platform=${ARCH} ${IMAGE}
COPY --from=builder /build /
#WORKDIR /usr/local/sqlmigration
ENV DB_URL=
ENV DB_PASSWORD=
ENV DB_PASSWORD_FILE=
ENV DB_TARGET_VERSION=
ENV MIGRATION_DIR=/data
#
# Volumes make more problems than benefits...
# For some case we want to embed data in /data, but this is not possible due volume directive.
#
# https://stackoverflow.com/questions/44020785/remove-a-volume-in-a-dockerfile
# https://stackoverflow.com/questions/40006278/prevent-volume-creation-on-docker-run
#
# Comment it temporary while
#VOLUME /data
#VOLUME /etc/sqlmigration/secrets /run/secrets
USER node
ENTRYPOINT [ "/usr/local/bin/docker-entrypoint.sh" ]
