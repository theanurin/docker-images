ARG BUILD_IMAGE=alpine:3.12

FROM ${BUILD_IMAGE}

 RUN \
	apk add --no-cache gcc musl-dev python3-dev python3 py3-pip && \
	pip install --no-cache-dir --upgrade pip && \
	pip install --no-cache-dir fontawesome_markdown==0.2.6 mkdocs==1.1.2 mkdocs-material==5.5.12 mkdocs-markdownextradata-plugin==0.1.7 pathlib==1.0.1 && \
	apk del gcc musl-dev python3-dev

WORKDIR /data
ENV PYTHONPATH=/data/site-packages
VOLUME /data
EXPOSE 8000
ENTRYPOINT [ "mkdocs", "serve", "--dev-addr", "0.0.0.0:8000", "--config-file" ]
CMD [ "mkdocs.yml" ]
