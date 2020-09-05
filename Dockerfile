FROM python:3.7

RUN \
	pip install --upgrade pip && \
	pip install fontawesome_markdown mkdocs mkdocs-material mkdocs-markdownextradata-plugin pathlib

WORKDIR /development
ENV PYTHONPATH=/development/site-packages
ENTRYPOINT [ "mkdocs", "serve", "--dev-addr", "0.0.0.0:8000", "--config-file" ]
CMD [ "mkdocs.yml" ]
