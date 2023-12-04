#!/bin/sh

if [ -z "${MIGRATION_DIR}" ]; then
	MIGRATION_DIR="/data"
fi

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
		if [ ! -d "${MIGRATION_DIR}" ]; then
			echo "Container does not have embedded migration scripts in ${MIGRATION_DIR}" >&2
			exit 1
		fi
		ENVARGS="migration.directory=${MIGRATION_DIR}"
		if [ -n "${POSTGRES_URL}" ]; then
			ENVARGS="${ENVARGS} postgres.url=${POSTGRES_URL}"
		fi
		if [ -n "${DB_TARGET_VERSION}" ]; then
			ENVARGS="${ENVARGS} migration.targetVersion=${DB_TARGET_VERSION}"
		fi
		[ -f "${MIGRATION_DIR}/BANNER" ] && cat "${MIGRATION_DIR}/BANNER"
		exec env -i ${ENVARGS} /usr/local/sqlmigration/bin/install.js $*
		;;
	rollback)
		shift
		if [ -n "${POSTGRES_URL}" ]; then
			ENVARGS="${ENVARGS} postgres.url=${POSTGRES_URL}"
		fi
		if [ -n "${DB_TARGET_VERSION}" ]; then
			ENVARGS="${ENVARGS} migration.targetVersion=${DB_TARGET_VERSION}"
		fi
		exec env -i ${ENVARGS} /usr/local/sqlmigration/bin/rollback.js $*
		;;
	*)
		exec /bin/sh -c "$@"
		;;
esac
