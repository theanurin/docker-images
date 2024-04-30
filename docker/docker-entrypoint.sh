#!/bin/sh

if [ -z "${1}" ]; then
	cat /usr/local/sqlmigration/README.md
	exit 1
fi

if [ -z "${MIGRATION_DIR}" ]; then
	MIGRATION_DIR="/data"
fi

if [ -z "${DB_URL}" ]; then
	echo "Fatal error: DB_URL environment was not provided." >&2
	exit 1
fi

if [ -n "${DB_PASSWORD_FILE}" -a  -n "${DB_PASSWORD}" ]; then
	echo "Fatal error: Both mutual exclusive variables were provided DB_PASSWORD_FILE and DB_PASSWORD." >&2
	exit 2
fi

if [ -n "${DB_PASSWORD_FILE}" ]; then
	DB_PASSWORD=$(cat "${DB_PASSWORD_FILE}")
fi

if [ -n "${DB_PASSWORD}" ]; then
	DB_URL=$(node -e "const url = new URL(\"${DB_URL}\"); url.password = encodeURIComponent(\"${DB_PASSWORD}\"); console.log(url.toString());")
fi

case "$1" in
	install)
		shift
		if [ ! -d "${MIGRATION_DIR}" ]; then
			echo "Container does not have embedded migration scripts in ${MIGRATION_DIR}" >&2
			exit 1
		fi
		ENVARGS="migration.directory=${MIGRATION_DIR}"
		if [ -n "${DB_URL}" ]; then
			ENVARGS="${ENVARGS} postgres.url=${DB_URL}"
		fi
		if [ -n "${DB_TARGET_VERSION}" ]; then
			ENVARGS="${ENVARGS} migration.targetVersion=${DB_TARGET_VERSION}"
		fi
		[ -f "${MIGRATION_DIR}/BANNER" ] && cat "${MIGRATION_DIR}/BANNER"
		exec env -i ${ENVARGS} /usr/local/sqlmigration/bin/install.js $*
		;;
	rollback)
		shift
		if [ -n "${DB_URL}" ]; then
			ENVARGS="${ENVARGS} postgres.url=${DB_URL}"
		fi
		if [ -n "${DB_TARGET_VERSION}" ]; then
			ENVARGS="${ENVARGS} migration.targetVersion=${DB_TARGET_VERSION}"
		fi
		exec env -i ${ENVARGS} /usr/local/sqlmigration/bin/rollback.js $*
		;;
	*)
		cat /usr/local/sqlmigration/README.md >&2
		exit 127
		;;
esac
