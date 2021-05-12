ARG BUILD_IMAGE=alpine:3.12

FROM ${BUILD_IMAGE}

RUN \
	apk add --no-cache gcc jpeg-dev libffi-dev musl-dev python3-dev python3 py3-pip zlib-dev jpeg cairo gobject-introspection pango && \
	pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir fontawesome_markdown==0.2.6 mkdocs==1.1.2 mkdocs-markdownextradata-plugin==0.2.4 mkdocs-material==7.1.4 mkdocs-pdf-export-plugin==0.5.8 pathlib==1.0.1 && \
    apk del gcc jpeg-dev libffi-dev musl-dev python3-dev zlib-dev

WORKDIR /data
ENV PYTHONPATH=/data/site-packages
VOLUME /data
EXPOSE 8000
ENTRYPOINT [ "mkdocs", "serve", "--dev-addr", "0.0.0.0:8000", "--config-file" ]
CMD [ "mkdocs.yml" ]
