ARG BUILD_IMAGE=alpine:3.13.6

FROM ${BUILD_IMAGE}

RUN \
  apk add --no-cache gcc g++ jpeg-dev libffi-dev musl-dev python3-dev py3-pip zlib-dev jpeg cairo gobject-introspection pango python3 && \
  pip install --no-cache-dir --upgrade pip && \
#  pip install --no-cache-dir fontawesome_markdown mkdocs mkdocs-markdownextradata-plugin mkdocs-material mkdocs-pdf-export-plugin pathlib && \
  pip install --no-cache-dir fontawesome_markdown==0.2.6 mkdocs==1.2.2 mkdocs-markdownextradata-plugin==0.2.4 mkdocs-material==7.2.6 mkdocs-pdf-export-plugin==0.5.9 pathlib==1.0.1 && \
  apk del gcc g++ jpeg-dev libffi-dev musl-dev python3-dev zlib-dev

WORKDIR /data
ENV PYTHONPATH=/data/site-packages
VOLUME /data
EXPOSE 8000
ENTRYPOINT [ "mkdocs", "serve", "--dev-addr", "0.0.0.0:8000", "--config-file" ]
CMD [ "mkdocs.yml" ]
