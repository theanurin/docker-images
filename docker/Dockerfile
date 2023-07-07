ARG IMAGE=fluentd:v1.16-1

FROM ${IMAGE}
USER root
RUN \
  fluent-gem install \
    fluent-plugin-elasticsearch \
    fluent-plugin-rewrite-tag-filter \
  && rm -rf /tmp/* /var/tmp/* /usr/lib/ruby/gems/*/cache/*.gem
COPY docker/docker-entrypoint.sh /usr/local/bin/docker-entrypoint-fluentd.sh
USER fluent
ENV LOG_LEVEL=info
ENTRYPOINT ["/usr/local/bin/docker-entrypoint-fluentd.sh"]