FROM python:3.7

RUN \
	pip install --upgrade pip && \
	pip install fontawesome_markdown==0.2.6 mkdocs==1.1.2 mkdocs-material==5.5.12 mkdocs-markdownextradata-plugin==0.1.7 pathlib==1.0.1 && \
	ln -sf bash /bin/sh

WORKDIR /development
ENV PYTHONPATH=/development/site-packages
ENTRYPOINT [ "mkdocs", "serve", "--dev-addr", "0.0.0.0:8000", "--config-file" ]
CMD [ "mkdocs.yml" ]
