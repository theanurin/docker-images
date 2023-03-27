ARG IMAGE=fluentd:v1.16-1

FROM ${IMAGE}
USER root
RUN \
  fluent-gem install \
    fluent-plugin-elasticsearch \
    fluent-plugin-rewrite-tag-filter \
  && rm -rf /tmp/* /var/tmp/* /usr/lib/ruby/gems/*/cache/*.gem
USER fluent