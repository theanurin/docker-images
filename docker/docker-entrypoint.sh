#!/bin/sh

function print_usage() {
	cat <<EOF >&2

Install/Up/MigrateUp:

  docker run --rm --tty --interactive \\
    --volume /PATH/TO/YOUR/MIGRATION/DIRECTORY:/data \\
    --env DB_URL="postgres://postgres@host.docker.internal:5432/emptytestdb" \\
    --env DB_TARGET_VERSION="v01.42" \\
    theanurin/sqlmigrationrunner install


Rollback/Down/MigrateDown:

  docker run --rm --tty --interactive \\
    --env DB_URL="postgres://postgres@host.docker.internal:5432/emptytestdb" \\
    --env DB_TARGET_VERSION="v01.40" \\
    theanurin/sqlmigrationrunner rollback

  !Note!: Rollback do not require any SQL scripts (rollback scripts are stored inside DB)

See:
- https://github.com/theanurin/docker-images/tree/sqlmigrationrunner
- https://hub.docker.com/r/theanurin/sqlmigrationbuilder
- https://docs.freemework.org/sql.misc.migration

EOF
}

if [ -z "${1}" ]; then
	print_usage
	exit 1
fi

if [ "${1}" == "--help" ]; then
	print_usage
	exit 0
fi

if [ -z "${MIGRATION_DIR}" ]; then
	MIGRATION_DIR="/data"
fi

if [ -z "${DB_URL}" ]; then
	echo "Fatal error: DB_URL environment was not provided." >&2
	exit 1
fi

if [ -n "${DB_USER_FILE}" -a  -n "${DB_USER}" ]; then
	echo "Fatal error: Both mutual exclusive variables were provided DB_USER_FILE and DB_USER." >&2
	exit 2
fi

if [ -n "${DB_USER_FILE}" ]; then
	DB_USER=$(cat "${DB_USER_FILE}")
fi

if [ -n "${DB_USER}" ]; then
	DB_URL=$(node -e "const url = new URL(\"${DB_URL}\"); url.username = encodeURIComponent(\"${DB_USER}\"); console.log(url.toString());")
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
	install|up|migration-up)
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
	rollback|down|migration-down)
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
		print_usage
		exit 127
		;;
esac
