#!/bin/sh

set -e

if [ "$(id -u)" = '0' ]; then
	if [ ! -d /data ]; then
		mkdir /data
	fi
	chown -R postgres:postgres /data
	chmod 750 /data

	# chown -R postgres:postgres /dbseed
	# chmod 750 /dbseed

	if [ ! -s "/data/PG_VERSION" ]; then
		echo "Creating database backend directory from /usr/share/postgresql.template ..."
		cp -a /usr/share/postgresql.template/* /data
	fi

	# Allows to use `docker commit` and `docker stop/start` (prevent dir creation on second run)
	if [ ! -d /run/postgresql ]; then
		mkdir          /run/postgresql
		chown postgres /run/postgresql
		chmod 775      /run/postgresql
	fi

	exec su -c "$0" postgres -- "$@"
else
	#if [ ! -s "/data/PG_VERSION" ]; then
	#	echo "Creating database backend directory from /usr/share/postgresql.template ..."
	#	cp -a /usr/share/postgresql.template/* /data
	#fi

	# Apply DBSeed only for first launch (in flavour to use `docker commit`)
	if [ ! -f /run/postgresql/init_done.flag -a -d /dbseed ]; then
		FILES=$(cd /dbseed && find * -type f -name '*.sql' -maxdepth 0 | sort)
		DB_DIRS=$(cd /dbseed && find * -type d -maxdepth 0 | sort)
		if [ -n "${FILES}" -o -n "${DB_DIRS}" ]; then
			echo "Found files in the /dbseed directory. Entering to update mode..."
		
			echo "Starting Postgres server to apply SQL updates..."
			PGUSER=postgres pg_ctl -D /data -o "-c listen_addresses=''" -w start

			if [ -n "${FILES}" ]; then
				if [ -f /DBNAME ]; then
					# Allows to inherit this image and set DB name in file /DBNAME
					DBNAME=$(cat /DBNAME)
				else
					DBNAME=devdb
				fi
				for FILE in ${FILES}; do
					echo "Apply SQL update /dbseed/${FILE} in database ${DBNAME}"
					/usr/bin/psql --pset=pager=off --variable=ON_ERROR_STOP=1 --username "postgres" --no-password --dbname "${DBNAME}" --file="/dbseed/${FILE}"
				done
			fi

			if [ -n "${DB_DIRS}" ]; then
				for DB_DIR in ${DB_DIRS}; do
					# DB_FILES=$(cd "/dbseed/${DB_DIR}" && find . -type f -name '*.sql' -maxdepth 1 | sort)
					DB_FILES=$(find "/dbseed/${DB_DIR}" -type f -name '*.sql' -maxdepth 1 | sort)
					for DB_FILE in ${DB_FILES}; do
						echo "Apply SQL update ${DB_FILE} in database ${DB_DIR}"
						/usr/bin/psql --pset=pager=off --variable=ON_ERROR_STOP=1 --username "postgres" --no-password --dbname "${DB_DIR}" --file="${DB_FILE}"
					done
				done
			fi

			echo "Stoping Postgres server ..."
			PGUSER=postgres pg_ctl -D /data -m fast -w stop

			echo "Updates was applied successfully. Entering to default mode..."
		fi
	fi

	touch /run/postgresql/init_done.flag
	exec postgres -D /data
fi
