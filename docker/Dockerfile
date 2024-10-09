ARG ALPINE_BUILD=3.19.4

FROM alpine:${ALPINE_BUILD}

ARG VER_OPENLDAP=2.6.6-r1
ARG VER_LEGO=4.14.2-r4
ARG VER_PYTHON=3.11.10-r0
ARG VER_OPENSSL=3.1.7-r0

#
# Add OpenLDAP backends (just names)
# https://pkgs.alpinelinux.org/packages?name=openldap-back-*&branch=v3.19
ARG BACKENDS="ldap mdb null"

# Add OpenLDAP overlays (just names)
# https://pkgs.alpinelinux.org/packages?name=openldap-overlay-*&branch=v3.19
ARG OVERLAYS="memberof refint syncprov"

# Install packages
RUN apk add --no-cache \
  openldap~=${VER_OPENLDAP} \
  openldap-clients~=${VER_OPENLDAP} \
  $(for OVERLAY in ${OVERLAYS}; do echo -n "openldap-overlay-${OVERLAY}~=${VER_OPENLDAP} "; done) \
  $(for BACKEND in ${BACKENDS}; do echo -n "openldap-back-${BACKEND}~=${VER_OPENLDAP} "; done) \
  lego~=${VER_LEGO} \
  python3~=${VER_PYTHON} \
  openssl~=${VER_OPENSSL} \
  py-pip && \
  pip3 install --break-system-packages --upgrade pip && \
  pip3 install --break-system-packages requests

# Copy entrypoint script to root /
COPY --chown=root:root docker/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
COPY --chown=root:root dns-01-solvers/ /opt/dns-01-solvers/

# Expose ports:
# - 389 LDAP unsecured (ldap://)
# - 636 LDAP secured (ldaps://)
# - 80  used by CONFIG_LEGO_CHALLENGE_HTTP_01
# - 443 used by CONFIG_LEGO_CHALLENGE_TLS_ALPN_01
EXPOSE 80 389 443 636

VOLUME [ "/data/etc", "/data/db" ]

# CONFIG_OPENLDAP_MODE is one of
# - DIRECTORY for new layout https://www.openldap.org/doc/admin24/slapdconf2.html
# - FILE for old layout https://www.openldap.org/doc/admin24/slapdconfig.html
ENV CONFIG_OPENLDAP_MODE=DIRECTORY

# Space separated list of domains. Define this variable will enable LEGO. See https://go-acme.github.io/lego/
ENV CONFIG_LEGO_DOMAIN=

ENV CONFIG_LEGO_EMAIL=

# Additional LEGO opts. For example '--server=https://acme-staging-v02.api.letsencrypt.org/directory' for ACME staging endpoint.
ENV CONFIG_LEGO_OPTS=

# Enable HTTP-01 challenge solver. If "true", LEGO will start HTTP server on port 80 to publish acme-challenge token. YOU NEED TO PUBLISH PORT 80 TO INTERNET.
ENV CONFIG_LEGO_CHALLENGE_HTTP_01=

# Enable TLS-ALPN-01 challenge solver. If "true", LEGO will start HTTPS server on port 443. YOU NEED TO PUBLISH PORT 443 TO INTERNET.
ENV CONFIG_LEGO_CHALLENGE_TLS_ALPN_01=

# Name of DNS Provider to DNS-01 challenge solver. If set, LEGO will use DNS provider https://go-acme.github.io/lego/dns/
ENV CONFIG_LEGO_CHALLENGE_DNS_01_PROVIDER=

# DNS-01 specific.
# Comma separated list of the resolvers to use for performing recursive DNS queries.
# The default is to use the system resolvers, or Google's DNS resolvers if the system's cannot be determined.
ENV CONFIG_LEGO_CHALLENGE_DNS_01_RESOLVERS=

# DNS-01 Provider `exec` specific.
# Path to script to solve DNS-01 challange. 
# See https://go-acme.github.io/lego/dns/exec/
#ENV EXEC_PATH=/opt/dns-01-solvers/adm-tools.py
ENV EXEC_PATH=

# DNS-01 Provider `exec` specific.
# Time between DNS propagation check.
# See EXEC_POLLING_INTERVAL https://go-acme.github.io/lego/dns/exec/#additional-configuration
ENV EXEC_POLLING_INTERVAL=30

# DNS-01 Provider `exec` specific.
# Maximum waiting time for DNS propagation.
# See EXEC_PROPAGATION_TIMEOUT https://go-acme.github.io/lego/dns/exec/#additional-configuration
ENV EXEC_PROPAGATION_TIMEOUT=3600

# See for "debug-level" in man page for SLAPD https://linux.die.net/man/8/slapd
ENV SLAPD_DEBUG_LEVEL=

# Timeout in seconds to check certificate expiration
ENV SSL_CERT_EXPIRE_TIMEOUT=86400

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]