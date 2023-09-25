[![Docker Image Version](https://img.shields.io/docker/v/theanurin/openldap?sort=date&label=Version)](https://hub.docker.com/r/theanurin/openldap/tags)
[![Docker Image Size](https://img.shields.io/docker/image-size/theanurin/openldap?label=Image%20Size)](https://hub.docker.com/r/theanurin/openldap/tags)
[![Docker Pulls](https://img.shields.io/docker/pulls/theanurin/openldap?label=Pulls)](https://hub.docker.com/r/theanurin/openldap)
[![Docker Stars](https://img.shields.io/docker/stars/theanurin/openldap?label=Docker%20Stars)](https://hub.docker.com/r/theanurin/openldap)

# OpenLDAP (+ Let's Encrypt)

[OpenLDAP](https://www.openldap.org/) is an open source implementation of the **L**ightweight **D**irectory **A**ccess **P**rotocol.

## Image reason

* Secured endpoint with Let's Encrypt SSL certificate generation (at startup)
* Easy to update production environment (just re-create container)
* Easy to bring-up mirror

## Spec

### Environment variables

* `SLAPD_DEBUG_LEVEL` - slapd debug level (`-1` enable all debugging). See [Debugging Levels](https://www.openldap.org/doc/admin23/runningslapd.html) table.
* `CONFIG_LEGO_DOMAIN` - Enable [Lego](https://github.com/go-acme/lego) and define domain of your OpenLDAP server
  `CONFIG_LEGO_DOMAIN_2`, `CONFIG_LEGO_DOMAIN_3`, `CONFIG_LEGO_DOMAIN_4`, `CONFIG_LEGO_DOMAIN_5` - Additional domains.
  * `CONFIG_LEGO_EMAIL` - an email for LEGO account
  * `CONFIG_LEGO_CHALLENGE_HTTP_01` - Set to `true` to enable __HTTP-01__ challenge solver. Make sure that your container will be available from Internet on port 80 and binds to domain defined in CONFIG_LEGO_DOMAIN
  * `CONFIG_LEGO_CHALLENGE_TLS_ALPN_01` - Set to `true` to enable __TLS-ALPN-01__ challenge solver. Make sure that your container will be available from Internet on port 443 and binds to domain defined in CONFIG_LEGO_DOMAIN
  * `CONFIG_LEGO_CHALLENGE_DNS_01_PROVIDER` - Set to one of following values to enable __DNS-01__ challenge solver.
    * `exec` - TBD
    * `cloudflare` - TBD
* `SSL_CERT_EXPIRE_TIMEOUT` - Timeout in seconds to check certificate expiration. Default: `86400`
* TBD

### Expose ports

* `tcp/80` - insecure HTTP endpoint for ACME challenge (use http://)
* `tcp/389` - insecure LDAP endpoint (use ldap://)
* `tcp/443` - secured HTTP endpoint for ACME challenge (use https://)
* `tcp/636` - secured LDAP endpoint (use ldaps://)
 
### Volumes

* `/data/etc` - Configuration stuff
* `/data/etc/slapd-init.d` - Place here LDIF files that will deployed (one time) into new instance via `slapadd`. Probably good place to configure OpenLDAP modules, schemas, etc. But you unable to setup database here (due to `slapadd` is not intended for incremental use, see [thread](https://www.openldap.org/lists/openldap-software/200807/msg00101.html)...)
* `/data/db` - LDAP databases

### Defaults

* RootDN: `cn=config`
* RootPW: `openldap`

## Inside

* [slapd](https://www.openldap.org/software/man.cgi?query=slapd) - stand-alone LDAP daemon (server)
  * [ldap](https://pkgs.alpinelinux.org/package/v3.18/main/armhf/openldap-back-ldap) - OpenLDAP ldap backend
  * [mdb](https://pkgs.alpinelinux.org/package/v3.18/main/armhf/openldap-back-mdb) - OpenLDAP mdb backend
  * [null](https://pkgs.alpinelinux.org/package/v3.18/main/armhf/openldap-back-null) - OpenLDAP null backend
* [libraries](https://www.openldap.org/software/man.cgi?query=ldap) - implementing the LDAP protocol
* utilities, tools, and sample clients
* [LEGO](https://go-acme.github.io/lego/) - Let’s Encrypt client and ACME library written in Go.
* custom dns-01-solvers scripts to solve DNS-01 challenge:
  1. `tools.adm.py` for [Hosting Ukraine](https://www.ukraine.com.ua/)

## Launch

### Without SSL (probably for local usage)

```shell
docker run --rm --interactive --tty \
  --publish 389:389 \
  --env SLAPD_DEBUG_LEVEL=-1 \
  theanurin/openldap
```

See [Quick Start guide](https://github.com/theanurin/docker-images/blob/openldap/quick-start/README.md) for details.

### With ACME challenge HTTP_01

NOTE: The container's port 80 should be public available on your domain defined in CONFIG_LEGO_DOMAIN variable.

```shell
export CONFIG_LEGO_OPTS="--server=https://acme-staging-v02.api.letsencrypt.org/directory" # Skip this for ACME production environment
export CONFIG_LEGO_DOMAIN="ldap.example.org"
export CONFIG_LEGO_EMAIL="admin@example.org"
export CONFIG_LEGO_CHALLENGE_HTTP_01="true"

mkdir ldap-etc.local ldap-db.local

docker run --rm --interactive --tty \
  --env CONFIG_LEGO_OPTS --env CONFIG_LEGO_DOMAIN --env CONFIG_LEGO_EMAIL \
  --env CONFIG_LEGO_CHALLENGE_HTTP_01 \
  --mount "type=bind,source=$PWD/ldap-etc.local,target=/data/etc" \
  --mount "type=bind,source=$PWD/ldap-db.local,target=/data/db" \
  --publish 0.0.0.0:80:80 \
  --publish 127.0.0.1:389:389 \
  --publish 0.0.0.0:636:636 \
  theanurin/openldap
```

### With ACME challenge TLS_ALPN_01

NOTE: The container's port 443 should be public available on your domain defined in CONFIG_LEGO_DOMAIN variable.

```shell
export CONFIG_LEGO_OPTS="--server=https://acme-staging-v02.api.letsencrypt.org/directory" # Skip this for ACME production environment
export CONFIG_LEGO_DOMAIN="ldap.example.org"
export CONFIG_LEGO_EMAIL="admin@example.org"
export CONFIG_LEGO_CHALLENGE_TLS_ALPN_01="true"

mkdir ldap-etc.local ldap-db.local

docker run --rm --interactive --tty \
  --env CONFIG_LEGO_OPTS --env CONFIG_LEGO_DOMAIN --env CONFIG_LEGO_EMAIL \
  --env CONFIG_LEGO_CHALLENGE_TLS_ALPN_01 \
  --mount "type=bind,source=$PWD/ldap-etc.local,target=/data/etc" \
  --mount "type=bind,source=$PWD/ldap-db.local,target=/data/db" \
  --publish 127.0.0.1:389:389 \
  --publish 0.0.0.0:443:443 \
  --publish 0.0.0.0:636:636 \
  theanurin/openldap
```

### With ACME challenge DNS_01

NOTE: DNS_01 is perfect when you are not able to expose ACME web server ports. But you have to write own solver script if you use no-name DNS provider. See LEGO's ready to use [DNS Providers](https://go-acme.github.io/lego/dns/).

#### Cloudflare

```shell
export CONFIG_LEGO_OPTS="--server=https://acme-staging-v02.api.letsencrypt.org/directory" # Skip this for ACME production environment
export CONFIG_LEGO_DOMAIN="ldap.example.org"
export CONFIG_LEGO_EMAIL="admins@example.org"
export CONFIG_LEGO_CHALLENGE_DNS_01_PROVIDER="cloudflare"
export CONFIG_LEGO_CHALLENGE_DNS_01_RESOLVERS="arely.ns.cloudflare.com,cameron.ns.cloudflare.com"

export CLOUDFLARE_DNS_API_TOKEN=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
export CLOUDFLARE_ZONE_API_TOKEN=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

mkdir openldap-etc.local openldap-db.local

docker run --rm --interactive --tty \
  --env CONFIG_LEGO_OPTS --env CONFIG_LEGO_DOMAIN --env CONFIG_LEGO_EMAIL \
  --env CONFIG_LEGO_CHALLENGE_DNS_01_PROVIDER --env CONFIG_LEGO_CHALLENGE_DNS_01_RESOLVERS \
  --env CLOUDFLARE_EMAIL --env CLOUDFLARE_DNS_API_TOKEN --env CLOUDFLARE_ZONE_API_TOKEN \
  --mount "type=bind,source=$PWD/openldap-etc.local,target=/data/etc" \
  --mount "type=bind,source=$PWD/openldap-db.local,target=/data/db" \
  --publish 127.0.0.1:389:389 \
  --publish 0.0.0.0:636:636 \
  theanurin/openldap
```

#### Custom solver `tools.adm.py`

```shell
export CONFIG_LEGO_OPTS="--server=https://acme-staging-v02.api.letsencrypt.org/directory" # Skip this for ACME production environment
export CONFIG_LEGO_DOMAIN="ldap.example.org"
export CONFIG_LEGO_EMAIL="admin@example.org"
export CONFIG_LEGO_CHALLENGE_DNS_01_PROVIDER="exec"
export CONFIG_LEGO_CHALLENGE_DNS_01_RESOLVERS="ns313.inhostedns.org,ns213.inhostedns.net,ns113.inhostedns.com"
export EXEC_POLLING_INTERVAL=30
export EXEC_PROPAGATION_TIMEOUT=600
export EXEC_PATH="/opt/dns-01-solvers/tools.adm.py"
export ADM_TOOLS_ROOT_DOMAINS="example.org"
export ADM_TOOLS_API_TOKEN_FILE=/run/secrets/admtools_token

mkdir ldap-etc.local ldap-db.local

docker run --rm --interactive --tty \
  --env CONFIG_LEGO_OPTS --env CONFIG_LEGO_DOMAIN --env CONFIG_LEGO_EMAIL \
  --env CONFIG_LEGO_CHALLENGE_DNS_01_PROVIDER --env CONFIG_LEGO_CHALLENGE_DNS_01_RESOLVERS \
  --env EXEC_PATH --env EXEC_POLLING_INTERVAL --env EXEC_PROPAGATION_TIMEOUT \
  --env ADM_TOOLS_ROOT_DOMAINS --env ADM_TOOLS_API_TOKEN_FILE \
  --mount "type=bind,source=$PWD/ldap-etc.local,target=/data/etc" \
  --mount "type=bind,source=$PWD/ldap-db.local,target=/data/db" \
  --mount "type=bind,source=/path/to/admtools_token,target=/run/secrets/admtools_token" \
  --publish 127.0.0.1:389:389 \
  --publish 0.0.0.0:636:636 \
  theanurin/openldap
```


# Support

* Maintained by: [Max Anurin](https://anurin.name/)
* Where to get help: [Telegram](https://t.me/theanurin)
