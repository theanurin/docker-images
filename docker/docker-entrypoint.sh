#!/bin/sh

case "$1" in
	help)
		echo
		echo "-------------------------------------------------------------------------------------"
		echo "    Following a content of README.md. See more details inside sources repository.    "
		echo "-------------------------------------------------------------------------------------"
		echo
		echo
		cat /usr/local/sqlmigrationrunner-postgres/migration/README.md
		exit 1
		;;
	install)
		shift
		if [ ! -d /var/local/sqlmigrationrunner-postgres/migration ]; then
			echo "Container does not have embedded migration scripts in /var/local/sqlmigrationrunner-postgres/migration" >&2
			exit 1
		fi
		ENVARGS="migration.directory=/var/local/sqlmigrationrunner-postgres/migration"
		if [ -n "${POSTGRES_URL}" ]; then
			ENVARGS="${ENVARGS} postgres.url=${POSTGRES_URL}"
		fi
		if [ -n "${LOG_LEVEL}" ]; then
			ENVARGS="${ENVARGS} LOG_LEVEL=${LOG_LEVEL}"
		fi
		if [ -n "${TARGET_VERSION}" ]; then
			ENVARGS="${ENVARGS} migration.installTargetVersion=${TARGET_VERSION}"
		fi
		[ -f "/var/local/sqlmigrationrunner-postgres/migration/BANNER" ] && cat /var/local/sqlmigrationrunner-postgres/migration/BANNER
		exec env -i ${ENVARGS} /usr/local/sqlmigrationrunner-postgres/migration/bin/install.js $*
		;;
	rollback)
		shift
		if [ ! -d /var/local/sqlmigrationrunner-postgres/migration ]; then
			echo "Container does not have embedded migration scripts in /var/local/sqlmigrationrunner-postgres/migration" >&2
			exit 1
		fi
		ENVARGS="migration.directory=/var/local/sqlmigrationrunner-postgres/migration"
		if [ -n "${POSTGRES_URL}" ]; then
			ENVARGS="${ENVARGS} postgres.url=${POSTGRES_URL}"
		fi
		if [ -n "${LOG_LEVEL}" ]; then
			ENVARGS="${ENVARGS} LOG_LEVEL=${LOG_LEVEL}"
		fi
		if [ -n "${TARGET_VERSION}" ]; then
			ENVARGS="${ENVARGS} migration.rollbackTargetVersion=${TARGET_VERSION}"
		fi	
		[ -f "/var/local/sqlmigrationrunner-postgres/migration/BANNER" ] && cat /var/local/sqlmigrationrunner-postgres/migration/BANNER
		exec env -i ${ENVARGS} /usr/local/sqlmigrationrunner-postgres/migration/bin/rollback.js $*
		;;
	banner)
		shift
		if [ ! -d /var/local/sqlmigrationrunner-postgres/migration ]; then
			echo "Container does not have embedded migration scripts in /var/local/sqlmigrationrunner-postgres/migration" >&2
			exit 1
		fi
		if [ ! -f /var/local/sqlmigrationrunner-postgres/migration/BANNER ]; then
			echo "Embedded migration scripts does not have banner file: /var/local/sqlmigrationrunner-postgres/migration/BANNER" >&2
			exit 2
		fi
		exec cat /var/local/sqlmigrationrunner-postgres/migration/BANNER
		;;
	*)
		exec /bin/sh
		;;
esac
