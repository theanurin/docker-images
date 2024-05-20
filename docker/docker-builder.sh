#!/bin/sh

set -Eeo pipefail
# TODO swap to -Eeuo pipefail above (after handling all potentially-unset variables)

if [ "$(id -u)" = '0' ]; then
	echo "Started as user 'root'."

	if [ -d /usr/share/postgresql.template ]; then
		mv /usr/share/postgresql.template /data
	else
		mkdir -p /data
	fi
	chown -R postgres /data
	chmod 700 /data

	mkdir -p /build/usr/share/postgresql.template
	chown -R postgres /build/usr/share/postgresql.template
	chmod 700 /build/usr/share/postgresql.template

	mkdir -p /run/postgresql
	chown -R postgres /run/postgresql
	chmod 775 /run/postgresql

	echo "Restarting as user 'postgres'..."
	exec su -c "$0" postgres -- "$@"
else
	echo "Started as user '$(id -u -n)'."
fi

mkdir -p /data
chown -R "$(id -u)" /data 2>/dev/null
chmod 700 /data 2>/dev/null

if [ -f /DB_NAME ]; then
	# Allows to inherit this image and set DB name in file /DB_NAME
	DB_NAME=$(cat /DB_NAME)
else
	DB_NAME=devdb
fi

if [ -f /DB_USER ]; then
	# Allows to inherit this image and set DB user in file /DB_USER
	DB_USER=$(cat /DB_USER)
else
	DB_USER=devuser
fi

if [ -f /DB_OWNER ]; then
	# Allows to inherit this image and set DB owner in file /DB_OWNER
	DB_OWNER=$(cat /DB_OWNER)
else
	DB_OWNER=devadmin
fi

NEW_INSTALL=no
# look specifically for PG_VERSION, as it is expected in the DB dir
if [ ! -s "/data/PG_VERSION" ]; then
	NEW_INSTALL=yes

	echo "Initialize database backend directory"
	initdb -D /data --username="postgres"

	echo "Setup 'trust' for all hosts"
	{
		echo
		echo "host all all all trust"
	} >> "/data/pg_hba.conf"

	echo "Setup 'listen_addresses' to '0.0.0.0'"
	echo "listen_addresses = '0.0.0.0'" >> /data/postgresql.conf
fi

# internal start of server in order to allow set-up using psql-client
# does not listen on external TCP/IP and waits until start finishes
PGUSER=postgres pg_ctl -D /data -o "-c listen_addresses=''" -w start

alias psql='psql --pset=pager=off --variable=ON_ERROR_STOP=1 --username "postgres" --no-password'

if [ "${NEW_INSTALL}" == "yes" ]; then
	for NEW_USER in ${DB_USER} ${DB_OWNER}; do
		echo "Create an user: ${NEW_USER}"
		# psql --set user="$NEW_USER" -f <(echo "CREATE USER :user WITH LOGIN;")
		psql --set user="$NEW_USER" <<-'EOSQL'
			CREATE USER :user WITH LOGIN;
		EOSQL
	done
	unset NEW_USER

	echo "Create database: ${DB_NAME}"
	psql --set db="${DB_NAME}" <<-'EOSQL'
		CREATE DATABASE :"db" ;
	EOSQL

	echo "Grant admin privileges to: ${DB_OWNER}"
	psql --set db="${DB_NAME}" --set user="${DB_OWNER}" <<-'EOSQL'
		ALTER DATABASE :"db" OWNER TO :"user";
	EOSQL
fi

if [ -x /.builder-postgres.sh ]; then
	if [ -d /.builder-postgres.d ]; then
		echo "ERROR: Both mutual exclusive /.builder-postgres.sh file and /.builder-postgres.d directory are presented. Pls fix to continue." >&2
		exit 87
	fi

	echo "Executing /.builder-postgres.sh ..."
	/.builder-postgres.sh
else
	if [ -f /.builder-postgres.sh ]; then
		echo "WARN: A non-executable file /.builder-postgres.sh is presented. Maybe you forgot to chmod +x ..."
	fi

	# In user-build mode, this direcotry may occurs
	if [ -d /.builder-postgres.d ]; then
		FILES=$(cd /.builder-postgres.d && find * -type f -name '*.sql' -maxdepth 0 | sort)
		if [ -n "${FILES}" ]; then
			for FILE in ${FILES}; do
				echo "Appling SQL update /.builder-postgres.d/${FILE} in database ${DB_NAME} ..."
				psql --dbname "${DB_NAME}" --file="/.builder-postgres.d/${FILE}"
			done
		fi
	fi
fi


PGUSER=postgres pg_ctl -D /data -m fast -w stop

mv /data/* /build/usr/share/postgresql.template/

echo
echo 'PostgreSQL init process complete.'
echo
