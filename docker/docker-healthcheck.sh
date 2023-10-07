#!/bin/sh
#
# https://docs.docker.com/engine/reference/builder/#healthcheck
#

set -e

if [ ! -f /run/postgresql/init_done.flag ]; then
    # See for creation of /run/postgresql/init_done.flag in docker-entrypoint.sh
    echo "PostgreSQL does not initialized yet. Be patient..." >&2
    # 1: unhealthy - the container is not working correctly
    exit 1
fi

if ! pg_isready --dbname=devdb --username=devuser; then
    echo "PostgreSQL (pg_isready) is not ready yet. Be patient..." >&2
    # 1: unhealthy - the container is not working correctly
    exit 1
fi

if [ ! -S /run/postgresql/.s.PGSQL.5432 ]; then
    echo "PostgreSQL socket is not ready yet. Be patient..." >&2
    # 1: unhealthy - the container is not working correctly
    exit 1
fi

# 0: success - the container is healthy and ready for use
exit 0
