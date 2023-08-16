#!/bin/sh

set -e

if [ "$(id -u)" = '0' ]; then
	if [ ! -d /data ]; then
		mkdir /data
	fi
	chown -R postgres:postgres /data
	chmod 750 /data

	chown -R postgres:postgres /updates
	chmod 750 /updates

	if [ ! -s "/data/PG_VERSION" ]; then
		echo "Creating database backend directory from /usr/share/postgresql.template ..."
		cp -a /usr/share/postgresql.template/* /data
	fi

	exec su -c "$0" postgres -- "$@"
else
	#if [ ! -s "/data/PG_VERSION" ]; then
	#	echo "Creating database backend directory from /usr/share/postgresql.template ..."
	#	cp -a /usr/share/postgresql.template/* /data
	#fi

	FILES=$(find /updates -type f -name '*.sql' | sort)
	if [ -n "${FILES}" ]; then
		echo "Found files in the /updates directory. Entering to update mode..."
	
		echo "Starting Postgres server to apply SQL updates..."
		PGUSER=postgres pg_ctl -D /data -o "-c listen_addresses=''" -w start

		if [ -f /DBNAME ]; then
			DBNAME=$(cat /DBNAME)
		else
			DBNAME=devdb
		fi
		for FILE in ${FILES}; do
			echo "Apply SQL update: ${FILE}"
			/usr/bin/psql --pset=pager=off --variable=ON_ERROR_STOP=1 --username "postgres" --no-password --dbname "${DBNAME}" --file="${FILE}"
		done

		echo "Stoping Postgres server ..."
		PGUSER=postgres pg_ctl -D /data -m fast -w stop

		echo "Updates was applied successfully. Entering to default mode..."
	fi

	exec postgres -D /data
fi

