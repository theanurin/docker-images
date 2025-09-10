ARG BUILD_IMAGE=alpine:3.22.1

FROM ${BUILD_IMAGE}

RUN \
  apk add --no-cache gcc g++ jpeg-dev libffi-dev musl-dev python3-dev py3-pip zlib-dev jpeg cairo gobject-introspection pango python3 && \
  pip config set global.break-system-packages true && \
  pip install --no-cache-dir --upgrade pip && \
  pip install --no-cache-dir fontawesome-in-markdown==0.2.1 mkdocs==1.6.1 mkdocs-markdownextradata-plugin==0.2.6 mkdocs-material==9.6.19 mkdocs-pdf-export-plugin==0.5.10 pathlib==1.0.1
WORKDIR /data
ENV PYTHONPATH=/data/site-packages
VOLUME /data
EXPOSE 8000
ENTRYPOINT [ "mkdocs", "serve", "--dev-addr", "0.0.0.0:8000", "--config-file" ]
CMD [ "mkdocs.yml" ]
