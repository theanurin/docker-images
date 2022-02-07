[![Docker Build Status](https://img.shields.io/docker/cloud/build/zxteamorg/infra.openldap?label=Build%20Status)](https://hub.docker.com/r/zxteamorg/infra.openldap/builds)
[![Docker Image Version](https://img.shields.io/docker/v/zxteamorg/infra.openldap?sort=date&label=Version)](https://hub.docker.com/r/zxteamorg/infra.openldap/tags)
[![Docker Image Size](https://img.shields.io/docker/image-size/zxteamorg/infra.openldap?label=Image%20Size)](https://hub.docker.com/r/zxteamorg/infra.openldap/tags)
[![Docker Pulls](https://img.shields.io/docker/pulls/zxteamorg/infra.openldap?label=Pulls)](https://hub.docker.com/r/zxteamorg/infra.openldap)


# OpenLDAP (+ Let's Encrypt)

[OpenLDAP](https://www.openldap.org/) is an open source implementation of the **L**ightweight **D**irectory **A**ccess **P**rotocol.

## Image reason

* Secured endpoint with Let's Encrypt SSL certificate generation (at startup)
* Easy to update production enviroment (just re-create container)
* Easy to bring-up mirror


## Spec

### Environment variables

TBD

### Expose ports

* `tcp/80` - insecured HTTP endpoint for ACME challenge (use http://)
* `tcp/389` - insecured LDAP endpoint (use ldap://)
* `tcp/443` - secured HTTP endpoint for ACME challenge (use https://)
* `tcp/636` - secured LDAP endpoint (use ldaps://)
 
### Volumes

* `/data/etc` - Configuration stuff.
* `/data/etc/slapd-init.d` - Place here LDIF files that will deployed (one time) into new instance.
* `/data/db`  - LDAP databases.

### Defaults

* RootDN: `cn=config`
* RootPW: `openldap`

## Inside

* [slapd](https://www.openldap.org/software/man.cgi?query=slapd) - stand-alone LDAP daemon (server)
* [libraries](https://www.openldap.org/software/man.cgi?query=ldap) - implementing the LDAP protocol
* utilities, tools, and sample clients
* [LEGO](https://go-acme.github.io/lego/) - Let’s Encrypt client and ACME library written in Go.
* custom dns-01-solvers scripts to solve DNS-01 challange:
	1. `tools.adm.py` for [Hosting Ukraine](https://www.ukraine.com.ua/)

## Launch

### With ACME challange HTTP_01

NOTE: The container's port 80 should be public available on your domain defined in CONFIG_LEGO_DOMAIN variable.


```bash
export CONFIG_LEGO_OPTS="--server=https://acme-staging-v02.api.letsencrypt.org/directory" # Skip this for ACME production environment
export CONFIG_LEGO_DOMAIN="ldap.your-domain.test"
export CONFIG_LEGO_EMAIL="admin@your-domain.test"
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
  zxteamorg/infra.openldap
```

### With ACME challange TLS_ALPN_01

NOTE: The container's port 443 should be public available on your domain defined in CONFIG_LEGO_DOMAIN variable.


```bash
export CONFIG_LEGO_OPTS="--server=https://acme-staging-v02.api.letsencrypt.org/directory" # Skip this for ACME production environment
export CONFIG_LEGO_DOMAIN="ldap.your-domain.test"
export CONFIG_LEGO_EMAIL="admin@your-domain.test"
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
  zxteamorg/infra.openldap
```

### With ACME challange DNS_01 (with custom solver `tools.adm.py`)

NOTE: DNS_01 is perfect when you are not able to expose ACME web server ports. But you have to write own solver script if you use no-name DNS provider. See LEGO's ready to use [DNS Providers](https://go-acme.github.io/lego/dns/).

```bash
export CONFIG_LEGO_OPTS="--server=https://acme-staging-v02.api.letsencrypt.org/directory" # Skip this for ACME production environment
export CONFIG_LEGO_DOMAIN="ldap.your-domain.test"
export CONFIG_LEGO_EMAIL="admin@your-domain.test"
export CONFIG_LEGO_CHALLENGE_DNS_01_PROVIDER="exec"
export CONFIG_LEGO_CHALLENGE_DNS_01_RESOLVERS="ns313.inhostedns.org,ns213.inhostedns.net,ns113.inhostedns.com"
export EXEC_POLLING_INTERVAL=30
export EXEC_PROPAGATION_TIMEOUT=600
export EXEC_PATH="/opt/dns-01-solvers/tools.adm.py"
export ADM_TOOLS_ROOT_DOMAINS="your-domain.test"
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
  zxteamorg/infra.openldap
```


## Support

* Maintained by: [ZXTeam](https://zxteam.org)
* Where to get help: [Telegram Channel](https://t.me/zxteamorg)
