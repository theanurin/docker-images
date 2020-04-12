#!/bin/sh

case "$1" in
	help)
		echo
		echo "-------------------------------------------------------------------------------------"
		echo "    Following a content of README.md. See more details inside sources repository.    "
		echo "-------------------------------------------------------------------------------------"
		echo
		echo
		cat /usr/local/sqlmigration/README.md
		exit 1
		;;
	install)
		shift
		if [ ! -d /data ]; then
			echo "Container does not have embedded migration scripts in /data" >&2
			exit 1
		fi
		ENVARGS="migration.directory=/data"
		if [ -n "${POSTGRES_URL}" ]; then
			ENVARGS="${ENVARGS} postgres.url=${POSTGRES_URL}"
		fi
		if [ -n "${DB_TARGET_VERSION}" ]; then
			ENVARGS="${ENVARGS} migration.targetVersion=${DB_TARGET_VERSION}"
		fi
		[ -f "/data/BANNER" ] && cat /data/BANNER
		exec env -i ${ENVARGS} /usr/local/sqlmigration/bin/install.js $*
		;;
	rollback)
		shift
		ENVARGS="migration.directory=/data"
		if [ -n "${POSTGRES_URL}" ]; then
			ENVARGS="${ENVARGS} postgres.url=${POSTGRES_URL}"
		fi
		if [ -n "${DB_TARGET_VERSION}" ]; then
			ENVARGS="${ENVARGS} migration.targetVersion=${DB_TARGET_VERSION}"
		fi
		[ -f "/data/BANNER" ] && cat /data/BANNER
		exec env -i ${ENVARGS} /usr/local/sqlmigration/bin/rollback.js $*
		;;
	banner)
		shift
		if [ ! -d /data ]; then
			echo "Container does not have embedded migration scripts in /data" >&2
			exit 1
		fi
		if [ ! -f /data/BANNER ]; then
			echo "Embedded migration scripts does not have banner file: /data/BANNER" >&2
			exit 2
		fi
		exec cat /data/BANNER
		;;
	*)
		exec /bin/sh
		;;
esac
